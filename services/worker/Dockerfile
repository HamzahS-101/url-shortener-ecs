FROM golang:1.27.3-trixie AS builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
# CGO off: one self-contained file that doesn't need the OS's C library, so it runs on a minimal base image
RUN CGO_ENABLED=0 go build -o /worker .


# busybox: tiny base that includes wget for the health check
FROM busybox:1.37

COPY --from=builder /worker /usr/local/bin/worker

USER 10001:10001
EXPOSE 8090

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD ["wget", "-qO-", "http://localhost:8090/healthz"]

CMD ["worker"]
