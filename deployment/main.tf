// main.tf
// Place inside the `deployment/` folder referenced by the Jenkinsfile.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "build_number" {
  description = "Jenkins build number (passed from Jenkins)"
  type        = string
  default     = "local"
}

variable "name_prefix" {
  description = "Prefix to use for the instance Name tag"
  type        = string
  default     = "Terraform"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["Default-VPC"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = tolist(data.aws_subnets.selected.ids)[0]

  tags = {
    Name = "${var.name_prefix}-${var.build_number}"
  }
}

output "instance_name" {
  description = "The Name tag of the created instance"
  value       = aws_instance.example.tags["Name"]
}
