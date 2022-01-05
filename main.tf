variable "awsprops" {
  type = map(string)
  default = {
    region       = "ap-south-1"
    vpc          = "vpc-0eb050163f165f86c"
    ami          = "ami-0912f71e06545ad88"
    itype        = "t2.micro"
    subnet       = "subnet-07c21859c51c8cf8c"
    publicip     = true
    keyname      = "myseckey"
    secgroupname = "IAC-Sec-Group"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "aws_security_group" "project_iac_sg" {

  name        = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id      = lookup(var.awsprops, "vpc")
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]


  }
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }


}


resource "aws_instance" "project_iac" {
  ami                         = lookup(var.awsprops, "ami")
  instance_type               = lookup(var.awsprops, "itype")
  subnet_id                   = lookup(var.awsprops, "subnet")
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  
  vpc_security_group_ids = [aws_security_group.project_iac_sg.id
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = {
    NAME        = "SERVER01"
    ENVIRONMENT = "DEV"
    OS          = "UBUNTU"
    MANAGED     = "IAC"
  }

  depends_on = [aws_security_group.project_iac_sg]


}

output "ec2instance" {

  value = aws_instance.project_iac.public_ip

}