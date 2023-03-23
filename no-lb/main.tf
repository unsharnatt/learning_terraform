terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-2"
}

module "web_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "security_web" {
  source  = "terraform-aws-modules/security-group/aws"
  # version = "4.17.1"
  name    = "vm_web"

  vpc_id      = module.web_vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp", "http-80-tcp"]

  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_rules            = ["all-all"]
}

resource "aws_instance" "vm_web" {
  # count       = 2
  # ami         = data.aws_ami.amazon_linux.id
  # ami         = "ami-0f5470fce514b0d36" # get from aws > ec2 > instances > Launch an instance
  ami           = data.aws_ami.tomcat_linux.id
  instance_type = var.instance_type

  subnet_id              = module.web_vpc.public_subnets[0]
  vpc_security_group_ids = [module.security_web.security_group_id]
  tags = {
    Name = "server for web"
    Env  = "dev"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  # version = "~> 8.0"

  name = "web-alb"

  load_balancer_type = "application"

  vpc_id             = module.web_vpc.vpc_id
  subnets            = module.web_vpc.public_subnets
  security_groups    = [module.security_web.security_group_id]

  target_groups = [
    {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = aws_instance.vm_web.id
          port = 80
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "dev"
  }
}

data "aws_ami" "tomcat_linux" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "bitnami-tomcat-*-x86_64-hvm-ebs-nami",
    ]
  }

  filter {
    name = "virtualization-type"
    values = [ "hvm"]
  }

  owners      = ["979382823631"] # bitnami
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
