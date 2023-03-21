terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

resource "aws_instance" "vm-web" {
  ami           = "ami-0f5470fce514b0d36" # get from aws > ec2 > instances > Launch an instance
  instance_type = var.instance_type

  tags = {
    Name = "server for web"
    Env  = "dev"
  }
}
