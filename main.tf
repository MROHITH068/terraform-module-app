
##Security Group
resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = var.sg_subnet_cidr
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.allow_ssh_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}

resource "aws_launch_template" "main" {
  name = "${var.component}-${var.env}"

#  block_device_mappings {
#    device_name = "/dev/sdf"
#
#    ebs {
#      volume_size = 20
#      encrypted = true
#      kms_key_id = var.kms_key_arn
#    }
#  }

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  image_id = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge({Name = "${var.component}-${var.env}",Monitor = "true"}, var.tags)
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh",{
    env = var.env
    component = var.component
  } ))
}



resource "aws_autoscaling_group" "main" {
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnets
  target_group_arns = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.component}-${var.env}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


##DNS Record
resource "aws_route53_record" "dns" {
  zone_id = "Z01893031FJEHFT2WJCRK"
  name    = "${var.component}-dev"
  type    = "CNAME"
  ttl     = 30
  records = [var.lb_dns_name]
}


resource "aws_lb_listener_rule" "main" {
  listener_arn = var.listener_arn
  priority     = var.lb_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = ["${var.component}-${var.env}.rohdevops.online"]
    }
  }
}


