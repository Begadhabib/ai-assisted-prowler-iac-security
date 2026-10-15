
# Intentionally vulnerable IaC security lab.
# Use only for short-lived testing and destroy after the lab.

# Get the current AWS account and region
data "aws_caller_identity" "current" {}

# Find a recent Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Networking
resource "aws_vpc" "lab" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "ai-iac-security-lab-vpc"
    Environment = "security-lab"
  }
}

resource "aws_subnet" "lab" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name        = "ai-iac-security-lab-subnet"
    Environment = "security-lab"
  }
}

# S3 bucket name must be globally unique
resource "aws_s3_bucket" "app_data" {
  bucket = "ai-iac-lab-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  tags = {
    Name        = "ai-iac-test"
    Environment = "security-lab"
  }
}

# Intentionally missing explicit encryption, versioning,
# and public access block configuration for future security scanning.

resource "aws_security_group" "app_sg" {
  name        = "ai-iac-test-sg"
  description = "Intentionally insecure security group for IaC scanning"
  vpc_id      = aws_vpc.lab.id

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
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.lab.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = false

  # Intentionally permits IMDSv1
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  # Intentionally disables EBS encryption
  root_block_device {
    encrypted = false
  }

  tags = {
    Name        = "ai-iac-test-instance"
    Environment = "security-lab"
  }
}
