variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_filter" {
  description = "Name filter and owner for AMI"

  type    = object ({
    name  = string
    owner = string
  })

  default = {
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631" # Bitnami
  }
}

variable "environment" {
  description = "Deployment environment"

  type        = object ({
    name           = string
    network_prefix = string
  })
  default = {
    name           = "dev"
    network_prefix = "10.0"
  }
}

variable "asg_min" {
  description = "Minimum instance count for the ASG"
  default     = 1
}

variable "asg_max" {
  description = "Maximum instance count for the ASG"
  default     = 1
}