provider "aws" {
  region = "us-east-1"
}

# Security Group
resource "aws_security_group" "flask_sg" {
  name        = "flask-docker-sg"
  description = "Allow SSH and Flask port 5000"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["70.120.67.69/32"] # Replace with ipchicken.com IP
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Flask accessible to public
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "flask_ec2" {
  ami                    = "ami-0c02fb55956c7d316" # Ubuntu 22.04 (us-east-1)
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  tags = {
    Name = "FlaskDockerApp"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "flask_bucket" {
  bucket = "flask-docker-bucket-${random_id.bucket_id.hex}"
  acl    = "private"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}
