# Create Load balancer - web tier
resource "aws_lb" "three-tier-web-lb" {
  name               = "three-tier-web-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.three-tier-alb-sg-1.id]
  subnets         = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]

  tags = {
    Environment = "three-tier-web-lb"
  }
}
# SECURITY GROUP
# Create Security Group for ALB (Load Balancer)
resource "aws_security_group" "three-tier-alb-sg-1" {
  name        = "three-tier-alb-sg-1"
  description = "Security group for the web tier Application Load Balancer"
  vpc_id      = aws_vpc.three-tier-vpc.id

  # Allow inbound HTTP traffic on port 80
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

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-alb-sg-1"
  }
}



# create load balancer target group - web tier
resource "aws_lb_target_group" "three-tier-web-lb-tg" {
  name     = "three-tier-web-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id

}

# Create Load Balancer listener - web tier
resource "aws_lb_listener" "three-tier-web-lb-listner" {
  load_balancer_arn = aws_lb.three-tier-web-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three-tier-web-lb-tg.arn
  }
}


# Register the instances with the target group - web tier
resource "aws_autoscaling_attachment" "three-tier-web-asattach" {
  autoscaling_group_name = aws_autoscaling_group.three-tier-web-asg.name
  lb_target_group_arn    = aws_lb_target_group.three-tier-web-lb-tg.arn

}
