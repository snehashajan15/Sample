# Provider configuration
provider "aws" {
  region = "eu-north-1"
}

# Create SSH key
resource "aws_key_pair" "deploy_key" {
  key_name   = "my-deploy-key"
  public_key = file("keys/terraform_key.pub")
}


# Security group for SSH and HTTP
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
  ami           = " ami-01fd6fa49060e89a6"
 # Change if not in us-east-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deploy_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "AutomationServer"
  }
}

# Output public IP
output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}
