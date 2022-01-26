data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]

  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "tls_private_key" "atul_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "atul_auth" {
  key_name   = var.key_name
  public_key = tls_private_key.atul_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.atul_key.private_key_pem}' > ./myKey.pem"
  }
}

resource "aws_instance" "private-instance" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  tags = {
    Name = "PrivateInstance"
  }
  user_data              = file(var.user_data_path)
  key_name               = aws_key_pair.atul_auth.id
  vpc_security_group_ids = [var.private_sg]
  subnet_id              = var.private_subnets[count.index]

  root_block_device {
    volume_size = var.vol_size
  }
}

resource "aws_lb_target_group_attachment" "dev-tg-attachment" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.private-instance[count.index].id
  port             = 80
}
