terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

variable "avail_zone" {
  default = "eu-central-1a"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "env_prefix" {
  default = "dev"
}
variable "public_key_location" {
  default = "/var/jenkins_home/keys/is_rsa.pub"
}
variable "inst_num" {
  default = 1
}


resource "aws_key_pair" "my-key" {
  key_name   = "${var.env_prefix}-server-key"
  public_key = file("${var.public_key_location}")
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "latest-free-tier-image" {
  most_recent = "true"
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211021"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "evo" {
  count                   = var.inst_num
  key_name                = aws_key_pair.my-key.key_name
  availability_zone       = var.avail_zone
  
  ami                     = data.aws_ami.latest-free-tier-image.id
  instance_type           = var.instance_type
  vpc_security_group_ids  = [ aws_security_group.allow_ingress.id, aws_security_group.allow_egress.id ]

  tags = {
    Name = "${var.env_prefix}-server-${count.index + 1}"
  }
}


resource "aws_security_group" "allow_ingress" {
  vpc_id      = data.aws_vpc.default.id
  
  name        = "allow_ingress"
  description = "Allow ingress"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_egress" {
  vpc_id      = data.aws_vpc.default.id

  name        = "allow_egress"
  description = "Allow egress"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip" {
  count    = var.inst_num
  vpc      = true
  instance = aws_instance.evo[count.index].id
}

output "ec2_public_ip" {
  value = aws_eip.ip[*].public_ip
}