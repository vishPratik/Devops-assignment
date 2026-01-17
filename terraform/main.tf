# main.tf - WITH INTENTIONAL VULNERABILITIES
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "DevSecOps-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "Main-IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# INTENTIONAL VULNERABILITY 1: SSH open to entire world
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id
  
  # VULNERABILITY: SSH open to 0.0.0.0/0
  ingress {
    description = "SSH from anywhere"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Web traffic
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Custom web app port"
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # INTENTIONAL VULNERABILITY 2: Overly permissive egress
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "Web-Security-Group"
  }
}

# INTENTIONAL VULNERABILITY 3: No encryption on EBS volume
resource "aws_instance" "web_server" {
  ami                    = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  # VULNERABILITY: No encryption on root volume
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    # encrypted   = false  # Missing encryption - INTENTIONAL
  }
  
  # User data to install Docker and run our app
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              
              # Create app directory
              mkdir -p /app
              cd /app
              
              # Create Dockerfile
              cat > Dockerfile << 'DOCKERFILE'
              FROM python:3.9-slim
              WORKDIR /app
              COPY requirements.txt .
              RUN pip install Flask==2.3.3
              COPY app.py .
              CMD ["python", "app.py"]
              DOCKERFILE
              
              # Create requirements.txt
              echo "Flask==2.3.3" > requirements.txt
              
              # Create app.py
              cat > app.py << 'APP'
              from flask import Flask
              app = Flask(__name__)
              @app.route('/')
              def home():
                  return "DevSecOps Assignment - Running on AWS!"
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              APP
              
              # Build and run
              docker build -t devops-app .
              docker run -d -p 5000:5000 --name devops-app devops-app
              EOF
  
  tags = {
    Name = "DevSecOps-WebServer"
  }
  
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "web_eip" {
  domain = "vpc"
}


output "instance_id" {
  value = aws_instance.web_server.id
}

output "public_ip" {
  value = aws_eip.web_eip.public_ip
}

output "ssh_command" {
  value = "ssh -i your-key.pem ubuntu@${aws_eip.web_eip.public_ip}"
}

output "web_url" {
  value = "http://${aws_eip.web_eip.public_ip}:5000"
}