# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "admin_ip" {
  description = "Admin public IP without CIDR"
  type        = string
}

variable "web_port" {
  description = "Web application port"
  type        = number
  default     = 5000
}
