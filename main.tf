terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

#Defines the provider and region to use
provider "aws" {
  region = "us-east-1"
}

#Defines the SG and inbound/outbound rules
resource "aws_security_group" "jenkins" {
  name        = "terraform-jenkins-sg"
  description = "Allow SSH and Jenkins web access"

#Allows inbound SSH traffic on port 22 from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#Allows inbound traffic on port 8080 from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#Allows all outbound traffic to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Defines the EC2 instance and arguments
resource "aws_instance" "jenkins" {
  ami           = "ami-02d7fd1c2af6eead0" # Use the latest Amazon Linux 2 AMI for us-east-1
  instance_type = "t2.micro"
  key_name      = "your-key-pair-name" #Replace with the name of your key pair in us-east-1

  security_groups = [aws_security_group.jenkins.name]

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
                sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
                sudo yum upgrade
                sudo amazon-linux-extras install java-openjdk11 -y
                sudo yum install jenkins -y
                sudo systemctl enable jenkins
                sudo systemctl start jenkins
                EOF

  user_data_replace_on_change = true

  tags = {
    Name = "jenkins-server"
  }
}