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

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "web_port" {
  description = "Web application port"
  type        = number
  default     = 5000
}

variable "your_ip_address" {
  description = "Your public IP address for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # INTENTIONAL VULNERABILITY - We'll fix with AI
}
