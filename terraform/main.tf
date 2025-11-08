# Provider configuration
provider "aws" {
  region = "eu-north-1"
}

# Create SSH key pair in AWS using your local public key
resource "aws_key_pair" "deploy_key" {
  key_name   = "terraform_key"
  public_key = file("${path.module}/keys/terraform_key.pub")
}

# Security group allowing SSH (22) and HTTP (80)
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance (Ubuntu 22.04)
resource "aws_instance" "web" {
  ami           = "ami-01fd6fa49060e89a6" # Ubuntu 22.04 for eu-north-1
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deploy_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "AutomationServer"
  }

  # Optional: Define connection for provisioners or remote exec
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/keys/terraform_key")
    host        = self.public_ip
  }
}

# Output public IP
output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}
