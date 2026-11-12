package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
	_ "github.com/lib/pq"
)

var db *sql.DB
var sqsClient *sqs.Client

type ClickEvent struct {
	ShortCode string `json:"short_code"`
	IP        string `json:"ip"`
	UserAgent string `json:"user_agent"`
	Referer   string `json:"referer"`
	Timestamp string `json:"timestamp"`
}

func main() {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is required")
	}

	var err error
	db, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(3)
	db.SetConnMaxLifetime(5 * time.Minute)
	waitForDB()
	migrate()

	sqsQueue := os.Getenv("SQS_QUEUE_URL")
	if sqsQueue == "" {
		log.Fatal("SQS_QUEUE_URL is required")
	}

	awsCfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		log.Fatalf("Failed to load AWS config: %v", err)
	}
	sqsClient = sqs.NewFromConfig(awsCfg)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Health check endpoint
	go func() {
		mux := http.NewServeMux()
		mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
			dbStatus := "ok"
			pingCtx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
			defer cancel()
			if err := db.PingContext(pingCtx); err != nil {
				dbStatus = "unreachable"
				log.Printf("Health check: database unreachable: %v", err)
			}
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(map[string]string{"status": "ok", "database": dbStatus, "service": "worker"})
		})
		port := getEnv("HEALTH_PORT", "8090")
		log.Printf("Worker health check on :%s", port)
		http.ListenAndServe(":"+port, mux)
	}()

	// Graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigChan
		log.Println("Shutting down worker...")
		cancel()
	}()

	log.Println("Analytics worker started, polling SQS...")
	pollSQS(ctx, sqsQueue)
}

func migrate() {
	migrations := []string{
		`CREATE TABLE IF NOT EXISTS click_events (
			id SERIAL PRIMARY KEY,
			short_code VARCHAR(16) NOT NULL,
			ip_address VARCHAR(45),
			user_agent TEXT,
			referer TEXT,
			clicked_at TIMESTAMP NOT NULL,
			processed_at TIMESTAMP DEFAULT NOW()
		)`,
		`CREATE INDEX IF NOT EXISTS idx_click_events_short_code ON click_events(short_code)`,
		`CREATE INDEX IF NOT EXISTS idx_click_events_clicked_at ON click_events(clicked_at)`,
		`CREATE TABLE IF NOT EXISTS click_stats_hourly (
			short_code VARCHAR(16) NOT NULL,
			hour TIMESTAMP NOT NULL,
			clicks INTEGER DEFAULT 0,
			unique_ips INTEGER DEFAULT 0,
			PRIMARY KEY (short_code, hour)
		)`,
	}
	for _, m := range migrations {
		if _, err := db.Exec(m); err != nil {
			log.Fatalf("Migration failed: %v", err)
		}
	}
	log.Println("Worker migrations complete")
}

func pollSQS(ctx context.Context, queueURL string) {
	for {
		select {
		case <-ctx.Done():
			log.Println("Worker stopped")
			return
		default:
			if !dbReachable(ctx) {
				log.Println("Database unreachable, pausing SQS polling")
				time.Sleep(10 * time.Second)
				continue
			}
			messages := receiveSQSMessages(ctx, queueURL)
			for _, msg := range messages {
				body := aws.ToString(msg.Body)
				if err := processClickEvent(body); err != nil {
					log.Printf("Failed to process event: %v", err)
					continue
				}
				deleteSQSMessage(ctx, queueURL, msg.ReceiptHandle)
				log.Printf("Processed click event: %s", body)
			}
		}
	}
}

func dbReachable(ctx context.Context) bool {
	pingCtx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	return db.PingContext(pingCtx) == nil
}

func receiveSQSMessages(ctx context.Context, queueURL string) []types.Message {
	out, err := sqsClient.ReceiveMessage(ctx, &sqs.ReceiveMessageInput{
		QueueUrl:            aws.String(queueURL),
		MaxNumberOfMessages: 10,
		WaitTimeSeconds:     20,
	})
	if err != nil {
		if ctx.Err() == nil {
			log.Printf("Failed to receive messages: %v", err)
			time.Sleep(5 * time.Second)
		}
		return nil
	}
	return out.Messages
}

func deleteSQSMessage(ctx context.Context, queueURL string, receiptHandle *string) {
	_, err := sqsClient.DeleteMessage(ctx, &sqs.DeleteMessageInput{
		QueueUrl:      aws.String(queueURL),
		ReceiptHandle: receiptHandle,
	})
	if err != nil {
		log.Printf("Failed to delete message: %v", err)
	}
}

func processClickEvent(raw string) error {
	var event ClickEvent
	if err := json.Unmarshal([]byte(raw), &event); err != nil {
		return err
	}

	clickedAt, err := time.Parse(time.RFC3339, event.Timestamp)
	if err != nil {
		clickedAt = time.Now().UTC()
	}

	tx, err := db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Insert raw click event
	_, err = tx.Exec(
		`INSERT INTO click_events (short_code, ip_address, user_agent, referer, clicked_at)
		 VALUES ($1, $2, $3, $4, $5)`,
		event.ShortCode, event.IP, event.UserAgent, event.Referer, clickedAt,
	)
	if err != nil {
		return err
	}

	// Update hourly aggregation
	hour := clickedAt.Truncate(time.Hour)
	_, err = tx.Exec(
		`INSERT INTO click_stats_hourly (short_code, hour, clicks, unique_ips)
		 VALUES ($1, $2, 1, 1)
		 ON CONFLICT (short_code, hour)
		 DO UPDATE SET clicks = click_stats_hourly.clicks + 1`,
		event.ShortCode, hour,
	)
	if err != nil {
		return err
	}

	// Update total click count
	_, err = tx.Exec(`UPDATE urls SET clicks = clicks + 1 WHERE id = $1`, event.ShortCode)
	if err != nil {
		return err
	}

	return tx.Commit()
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func waitForDB() {
	for i := 0; i < 30; i++ {
		if err := db.Ping(); err == nil {
			return
		}
		log.Printf("Waiting for database... (%d/30)", i+1)
		time.Sleep(time.Second)
	}
	log.Fatal("Database not ready after 30s")
}
