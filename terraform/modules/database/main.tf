resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "-_"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "db" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period    = 1
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  apply_immediately          = true
  skip_final_snapshot        = true
  deletion_protection        = false

  tags = {
    Name = "${var.project_name}-db"
  }
}

resource "aws_secretsmanager_secret" "database_url" {
  name                    = "${var.project_name}/database-url"
  description             = "PostgreSQL connection string for the api, worker and dashboard"
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-database-url"
  }
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = "postgresql://${var.db_username}:${random_password.db_password.result}@${aws_db_instance.db.address}:${aws_db_instance.db.port}/${var.db_name}?sslmode=require"
}
