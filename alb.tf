
resource "aws_security_group" "openvpn_alb_sg" {
  name        = "${var.PREFIX}_alb_sg"
  description = "sg for application load balancer to redirect traffic from http to https"
  vpc_id      = aws_vpc.openvpn_vpc.id



  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.PREFIX}_alb_sg"
  }

}


resource "aws_lb" "openvpn_alb" {
  name               = "${var.PREFIX}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.openvpn_alb_sg.id]
  subnets            = [aws_subnet.openvpn_public_subnet[0].id, aws_subnet.openvpn_public_subnet[1].id, aws_subnet.openvpn_public_subnet[2].id]

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.id
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = {
    Name = "${var.PREFIX}_alb"
  }
}


resource "aws_lb_target_group" "openvpn_alb_tg" {
  name        = "${var.PREFIX}-alb-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.openvpn_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    matcher             = "302"
    protocol            = "HTTPS"
  }
}

resource "aws_lb_target_group_attachment" "openvpn_register_targets" {
  target_group_arn = aws_lb_target_group.openvpn_alb_tg.arn
  target_id        = aws_instance.openvpn_server.id
  port             = 80
}

resource "aws_lb_listener" "openvpn_alb_http_listner" {
  load_balancer_arn = aws_lb.openvpn_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"


    }
  }
}






resource "aws_lb_listener" "openvpn_alb_https_listner" {
  load_balancer_arn = aws_lb.openvpn_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.SSL_CERT_ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openvpn_alb_tg.arn
  }
}

resource "aws_route53_record" "subdomain" {
  zone_id = var.ZONE_ID
  name    = var.SUB_DOMAIN
  type    = "A"

  alias {
    name                   = aws_lb.openvpn_alb.dns_name
    zone_id                = aws_lb.openvpn_alb.zone_id
    evaluate_target_health = false
  }
}
