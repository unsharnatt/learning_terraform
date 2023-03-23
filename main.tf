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

# data "aws_vpc" "default" {
#   default = true
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "security_web" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"
  name    = "vm_web"

  # vpc_id    = data.aws_vpc.default.id
  vpc_id      = module.vpc.public_subnets[0]

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp", "http-80-tcp"]

  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_rules            = ["all-all"]
}

#        "resource type" "resource name"
resource "aws_instance" "vm_web" {
  # count       = 2
  # ami         = data.aws_ami.ubuntu.id
  ami         = data.aws_ami.amazon_linux.id
  # ami           = "ami-0f5470fce514b0d36" # get from aws > ec2 > instances > Launch an instance
  instance_type = var.instance_type

  # vpc_security_group_ids = [aws_security_group.vm_web.id]
  # vpc_security_group_ids = [module.security_web.security_group_id]
  tags = {
    Name = "server for web"
    Env  = "dev"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
   owners      = ["amazon"]
}

# resource "aws_security_group" "vm_web" {
#   name        = "vm_web"
#   description = "allows http and https"

#   # vpc_id    = data.aws_vpc.default.id
#   vpc_id      = module.vpc.public_subnets[0]
# }

# resource "aws_security_group_rule" "vm_web_http_in" {
#   type                = "ingress"
#   from_port           = 80
#   to_port             = 80
#   protocol            = "tcp"
#   cidr_blocks         = ["0.0.0.0/0"]
#   security_group_id   = aws_security_group.vm_web.id
# }

# resource "aws_security_group_rule" "vm_web_https_in" {
#   type                = "ingress"
#   from_port           = 443
#   to_port             = 443
#   protocol            = "tcp"
#   cidr_blocks         = ["0.0.0.0/0"]
#   security_group_id   = aws_security_group.vm_web.id
# }

# resource "aws_security_group_rule" "vm_web_everything_out" {
#   type                = "egress"
#   from_port           = 0
#   to_port             = 0
#   protocol            = "-1"
#   cidr_blocks         = ["0.0.0.0/0"]
#   security_group_id   = aws_security_group.vm_web.id
# }

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
#     protocol    = "tcp"
#     cidr_blocks = ["1.0.0.0/32"] 
#   }
#   egress {
#     from_port = 0    # allow any port 
#     to_port   = 0
#     protocol  = "-1" # allow any protocol 
#   }
# }

# Security Group Rule
# resource "aws_security_group_rule" "https_inbound" {
#   type                = "ingress"
#   from_port           = 443
#   to_port             = 443
#   protocol            = "tcp"
#   cidr_blocks         = ["0.0.0.0/32"]
#   security_group_id   = aws_security_group.allow_tls.id
# }

