
# Intentionally vulnerable IaC test fixture.
# DO NOT apply this configuration to a real AWS environment.

resource "aws_s3_bucket" "app_data" {
  bucket = var.bucket_name

  tags = {
    Name        = "ai-iac-security-test"
    Environment = "security-lab"
  }
}

# Intentionally missing:
# - Explicit server-side encryption configuration
# - Versioning configuration
# - S3 public access block

resource "aws_security_group" "app_sg" {
  name        = "ai-iac-test-sg"
  description = "Intentionally vulnerable security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "INTENTIONALLY INSECURE - SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ai-iac-test-sg"
    Environment = "security-lab"
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Intentionally permits IMDSv1.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  # Intentionally disables EBS encryption.
  root_block_device {
    encrypted = false
  }

  tags = {
    Name        = "ai-iac-test-instance"
    Environment = "security-lab"
  }
}
