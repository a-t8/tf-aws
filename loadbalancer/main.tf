data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20211223.0-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {}

resource "aws_lb" "atul-lb" {
  name            = "atul-loadbalancer"
  subnets         = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout    = 400
}

resource "aws_lb_target_group_attachment" "atul-tg-attach" {
  target_group_arn = aws_lb_target_group.atul_tg.arn
  target_id        = aws_lb.atul-lb.id
}

resource "aws_lb_target_group" "atul_tg" {
  name     = "atul-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
  }
}

resource "aws_lb_listener" "atul_listener" {
  load_balancer_arn = aws_lb.atul-lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.atul_tg.arn
  }
}

resource "random_id" "atul_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
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

resource "aws_launch_configuration" "atul-launch-config" {
  name_prefix     = "atul-ec2-"
  image_id        = data.aws_ami.server_ami.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.atul_auth.id
  security_groups = [var.public_sg]
  user_data       = file(var.user_data_path)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "atul-asg" {
  name = "${aws_launch_configuration.atul-launch-config.name}-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 3
  health_check_type    = "ELB"
  target_group_arns    = [aws_lb_target_group.atul_tg.arn]
  launch_configuration = aws_launch_configuration.atul-launch-config.name
  vpc_zone_identifier  = [var.public_subnets[1]]
}
