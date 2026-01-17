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

# IMPORTANT: Replace with your actual public IP
variable "allowed_ssh_ips" {
  description = "List of IPs allowed for SSH access"
  type        = list(string)
  default     = [""0.0.0.0/0"]  # Replace 103.xxx1 with your actual IP
}