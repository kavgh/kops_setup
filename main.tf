locals {
  tags = {
    reason  = "kops"
    purpose = "kops-state-file"
  }
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = "kopstate"

  tags = local.tags
}

resource "aws_route53_zone" "this" {
  name = "kubevpro.kavdom.site"

  tags = local.tags
}

resource "aws_instance" "this" {
  ami                         = "ami-036841078a4b68e14"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.this.id
  vpc_security_group_ids      = [aws_security_group.this.id]
  user_data                   = file("./userdata.tftpl") #templatefile("./userdata.tftpl", {bucket = aws_s3_bucket.this.id, dns_zone = aws_route53_zone.this.name})

  tags = merge(local.tags, { Name = "kops-instance" })
}

data "aws_vpc" "this" {
  default = true
}

resource "aws_security_group" "this" {
  name   = "kops-sg"
  vpc_id = data.aws_vpc.this.id

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.this.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_iam_instance_profile" "this" {
  name = "kopsipe"
  role = aws_iam_role.this.name

  tags = local.tags
}

resource "aws_iam_role" "this" {
  name               = "kopsrole"
  assume_role_policy = data.aws_iam_policy_document.this.json

  tags = local.tags
}

data "aws_iam_policy_document" "this" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_key_pair" "this" {
  key_name   = "kops-pkey"
  public_key = file("~/.ssh/aws_ec2.pub")

  tags = local.tags
}