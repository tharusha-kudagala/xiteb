terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2" # Free-tier quota friendly
}

# 1) Networking
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "main-vpc"
    Environment = "exam"
  }
}

# Public Subnet for ALB + EC2 (AZ1)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-az1"
    Environment = "exam"
  }
}

# Public Subnet 2 for ALB + EC2 (AZ2)
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-az2"
    Environment = "exam"
  }
}

# Private subnet for RDS only (AZ1)
resource "aws_subnet" "private" {
  vpc_id                              = aws_vpc.main.id
  cidr_block                          = "10.0.3.0/24"
  availability_zone                   = "us-east-2a"
  private_dns_hostname_type_on_launch = "ip-name"

  tags = {
    Name        = "private-subnet-az1"
    Environment = "exam"
  }
}

# Private subnet 2 for RDS only (AZ2)
resource "aws_subnet" "private2" {
  vpc_id                              = aws_vpc.main.id
  cidr_block                          = "10.0.4.0/24"
  availability_zone                   = "us-east-2b"
  private_dns_hostname_type_on_launch = "ip-name"

  tags = {
    Name        = "private-subnet-az2"
    Environment = "exam"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-igw"
    Environment = "exam"
  }
}

# Route 0.0.0.0/0 → IGW for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "public-rt"
    Environment = "exam"
  }
}
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

# 2) Security Groups 

# ── EC2 SG: HTTP 80 + SSH 22 from anywhere
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name        = "ec2-sg"
    Environment = "exam"
  }
}

# ── RDS SG: only allow MySQL from EC2 SG
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-sg"
    Environment = "exam"
  }
}

# ── ALB SG: allow public HTTP
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name        = "alb-sg"
    Environment = "exam"
  }
}

# 3) RDS (private)  
resource "aws_db_subnet_group" "db_subnets" {
  name       = "wp-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private2.id] # two private subnets in different AZs

  tags = {
    Name        = "db-subnet-group"
    Environment = "exam"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "wp-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # free-tier
  allocated_storage      = 20
  db_name                = "wordpress"
  username               = "admin"
  password               = var.db_password
  multi_az               = false
  skip_final_snapshot    = true
  publicly_accessible    = false # critical
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name

  tags = {
    Name        = "mysql-db"
    Environment = "exam"
  }
}

# 4) EC2 WordPress  
resource "aws_instance" "wordpress" {
  ami                    = "ami-0d1b5a8c13042c939" # Ubuntu 24.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id # needs internet
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  # cloud-init installs Apache + PHP + WordPress then wires wp-config.php
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apache2 php php-mysql libapache2-mod-php wget unzip
    sudo systemctl enable apache2 && sudo systemctl start apache2

    cd /var/www/html
    sudo wget -q https://wordpress.org/latest.tar.gz
    sudo tar -xzf latest.tar.gz && sudo cp -r wordpress/* .
    sudo rm -rf wordpress latest.tar.gz
    sudo rm -f /var/www/html/index.html
    sudo chown -R www-data:www-data /var/www/html

    sudo cp wp-config-sample.php wp-config.php
    sudo sed -i "s/database_name_here/wordpress/" wp-config.php
    sudo sed -i "s/username_here/admin/"        wp-config.php
    sudo sed -i "s/password_here/${var.db_password}/" wp-config.php
    sudo sed -i "s/localhost/${aws_db_instance.mysql.address}/" wp-config.php
    sleep 3
    sudo systemctl restart apache2
    sudo systemctl restart apache2
  EOF

  tags = {
    Name        = "WordPressUbuntu"
    Environment = "exam"
  }
}

# 5) Application Load Balancer
# Target Group for HTTP
resource "aws_lb_target_group" "tg" {
  name     = "wp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "wp-tg"
    Environment = "exam"
  }
}

# Register the EC2 instance
resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.wordpress.id
  port             = 80
}

# ALB itself (public)
resource "aws_lb" "alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public2.id] # two public subnets in different AZs

  tags = {
    Name        = "wp-alb"
    Environment = "exam"
  }
}

# Listener routes HTTP → target group
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
