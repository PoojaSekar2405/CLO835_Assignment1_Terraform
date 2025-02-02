provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet by specifying an availability zone
data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  # Specify the exact availability zone to ensure only one subnet matches
  availability_zone = "us-east-1a" 

# Security Group to allow required ports
resource "aws_security_group" "allow_required_ports" {
  name        = "allow_required_ports"
  description = "Allow SSH, ICMP, HTTP, and custom ports"
  vpc_id      = data.aws_vpc.default.id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow custom ports
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow port 3307
  ingress {
    from_port   = 3307
    to_port     = 3307
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "vm" {
  ami                    = "ami-0c614dee691cbbf37" 
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default.id
  key_name               = "vockey" # Use the default key pair
  vpc_security_group_ids = [aws_security_group.allow_required_ports.id]
  associate_public_ip_address = true 

  tags = {
    Name = "MyTestVM"
  }
}

# Create two AWS ECR repositories with specified names and tags
resource "aws_ecr_repository" "mysql" {
  name = "clo835-mysql"

  tags = {
    Environment = "Production"
    Application = "Database"
  }
}

resource "aws_ecr_repository" "webapp" {
  name = "clo835-webapp"

  tags = {
    Environment = "Production"
    Application = "Web Application"
  }
}
