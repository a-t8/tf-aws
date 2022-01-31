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

resource "aws_launch_configuration" "atul-launch-configuration" {
  name_prefix     = "atul-ec2-"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.atul_auth.id
  security_groups = [var.private_sg]
  user_data       = file(var.user_data_path)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "atul-autoscaling-group" {
  name                 = "${aws_launch_configuration.atul-launch-configuration.name}-asg"
  min_size             = 1
  desired_capacity     = 2
  max_size             = 3
  health_check_type    = "ELB"
  target_group_arns    = [var.lb_target_group_arn]
  launch_configuration = aws_launch_configuration.atul-launch-configuration.name
  vpc_zone_identifier  = [var.private_subnets[0]]
}
resource "aws_autoscaling_policy" "dev-scaling-policy" {
  name = "dev-scaling-policy"
  scaling_adjustment = 3
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.atul-autoscaling-group.name
}