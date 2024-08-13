provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_instance" "nginx" {
  ami           = "ami-070b7c2988d4e2c89" # Replace with your valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.allow_http.id] # Use security group ID here
  tags = {
    ClusterID    = "101"
    AccountID    = "101"
    RoleID       = "1"
    Application  = "DevOpsHomeTask"
  }

  user_data = <<-EOF
    #!/bin/bash
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx
    sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/nginx.conf
    systemctl restart nginx
  EOF
}
