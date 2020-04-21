provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "ec2Apache" {
  ami           = "ami-0c322300a1dd5dc79" # RHEL
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.default.id}"
  user_data = <<-EOF
  #!/bin/bash
  yum install httpd -y
  systemctl start httpd
  systemctl enable httpd.service
  EOF
  tags = {
    Name = "Apache-Web"
  }
}

resource "aws_instance" "ec2NginX" {
  ami           = "ami-0c322300a1dd5dc79" # RHEL
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.default.id}"
    user_data = <<-EOF
  #!/bin/bash
  yum install nginx -y
  systemctl start nginx
  systemctl enable nginx
  EOF
  tags = {
    Name = "Nginx-Web"
  }
}

resource "aws_key_pair" "ssh-keys" {
  key_name   = "ec2_terraform_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLuLssmUAo7Nk9fJCHN4J3ksZ9Kc5cCean2u3Nqah7JOk3h9Onv1scnG3iZ+1XVG1ZVXtcXIE/hFPC/B5UJijxiVBnATIdYjtj6q78k+2HzeXnz2Uw8ONPTOEZMHCpVBVdYheFL6vBWCRaKv0qvfoXHF8pdJLZDiC8cdkUf/DUI8JqbcxSlbPSfITcaMWLWkf/r1TERY9ZWF9YDDd+6O3TKdiRSW/HHrzVHZLHWaPPGHZ9VtodH2mPvygUKXX9WuFCtHOJLu8dZYwbMF9k5Ln8nZsT9/bweiFI2/CSHSy6Sf/b28CuW4pzzzWvBu2Qgh8TZLjQaF3MQ5zAp++BFCzv"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}


resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "tf_sg" {
  name        = "terraform_sg"
  description = "Grupo de seguridad"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # “-1” significa TCP y UDP
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}