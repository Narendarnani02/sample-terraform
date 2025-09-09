terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Free-tier Amazon Linux 2 AMI
data "aws_ami" "free_amzn2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2", "amzn2-ami-hvm-*-x86_64-*"]
  }

  filter {
    name   = "free-tier-eligible"
    values = ["true"]
  }

  owners = ["amazon"]
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Random suffix for S3 bucket
resource "random_id" "bucket_suffix" {
  byte_length = 3
}

# S3 bucket
resource "aws_s3_bucket" "project_bucket" {
  bucket        = "${var.project_name}-logs-${random_id.bucket_suffix.hex}"
  acl           = "private"
  force_destroy = true
  tags = {
    Name = "${var.project_name}-bucket"
  }
}

# EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.free_amzn2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "<h1>Deployed via Terraform (Terraform-sample)</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
