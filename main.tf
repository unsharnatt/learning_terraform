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

resource "aws_vpc" "default" {
  default = true
}

#        "resource type" "resource name"
resource "aws_instance" "vm-web" {
  # count       = 2
  # ami         = data.aws_ami.ubuntu.id
  ami           = "ami-0f5470fce514b0d36" # get from aws > ec2 > instances > Launch an instance
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.blog.id]
  tags = {
    Name = "server for web"
    Env  = "dev"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_security_group" "allow_tls" {
  name        = "blog"
  description = "allows http and https"

  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "blog_http_in" {
  type                = "ingress"
  from_port           = 80
  to_port             = 80
  protocal            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]
  security_group_id   = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_https_in" {
  type                = "ingress"
  from_port           = 443
  to_port             = 443
  protocal            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]
  security_group_id   = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  type                = "engress"
  from_port           = 0
  to_port             = 0
  protocal            = "-1"
  cidr_blocks         = ["0.0.0.0/0"]
  security_group_id   = aws_security_group.blog.id
}

# ***EIP***
# resource "aws_eip" "blog" {
#   instance = aws_instance.blog.id
#   vpc      = true
# }

# ***static web in S3 resource***
# resource "aws_s3_bucket" "static-web" {
#   bucket = "unsharnatt-web-2023" # uniq
#   acl    = "private"
# }

# ***VPC resource***
# resource "aws_vpc" "QA" {
#   cidr_block = "10.0.0.0/16"  
# }
# resource "aws_vpc" "Staging" {
#   cidr_block = "10.1.0.0/16"  
# }
# resource "aws_vpc" "Prod" {
#   cidr_block = "10.2.0.0/16"  
# }

# ***Security Group (firewall) ***
# resource "aws_security_group" "allow_tls" {
#   ingress {
#     form_port   = 443
#     to_port     = 443
#     protocal    = "tcp"
#     cidr_blocks = ["1.0.0.0/32"] 
#   }
#   egress {
#     from_port = 0    # allow any port 
#     to_port   = 0
#     protocal  = "-1" # allow any protocal 
#   }
# }

# Security Group Rule
# resource "aws_security_group_rule" "https_inbound" {
#   type                = "ingress"
#   from_port           = 443
#   to_port             = 443
#   protocal            = "tcp"
#   cidr_blocks         = ["0.0.0.0/32"]
#   security_group_id   = aws_security_group.allow_tls.id
# }

