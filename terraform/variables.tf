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

variable "web_port" {
  description = "Web application port"
  type        = number
  default     = 5000
}

variable "admin_ip" {
  description = "Public IP allowed for SSH and HTTP access"
  type        = string
}


# IMPORTANT: Replace with your actual public IP
variable "allowed_ssh_ips" {
  description = "List of IPs allowed for SSH access"
  type        = list(string)
  default     = ["${var.admin_ip}/32"]
}