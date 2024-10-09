# Create an EC2 Auto Scaling Group - app
resource "aws_autoscaling_group" "three-tier-app-asg" {
  name = "three-tier-app-asg"
  launch_template {
    id      = aws_launch_template.three-tier-app-ltemplate.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.three-tier-pvt-sub-1.id, aws_subnet.three-tier-pvt-sub-2.id]
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2
}
# SECURITY GROUP
# Create Security Group for EC2 Instances in the Application Tier
resource "aws_security_group" "three-tier-ec2-asg-sg-app" {
  name        = "three-tier-ec2-asg-sg-app"
  description = "Security group for the application tier EC2 instances"
  vpc_id      = aws_vpc.three-tier-vpc.id

  # Allow inbound traffic from the Web Tier (ALB) on specific ports (e.g., 80 for HTTP)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-alb-sg-1.id] # Assuming this is the security group for your ALB
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-alb-sg-1.id] # Assuming this is the security group for your ALB
  }

  # Allow inbound traffic for MySQL on port 3306 from other application instances (if needed)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.three-tier-pvt-sub-1.cidr_block, aws_subnet.three-tier-pvt-sub-2.cidr_block] # Adjust as necessary
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-ec2-asg-sg-app"
  }
}


# Create a Launch Template for the EC2 instances
resource "aws_launch_template" "three-tier-app-ltemplate" {
  name_prefix   = "three-tier-app-ltemplate"
  image_id      = "ami-047126e50991d067b"
  instance_type = "t2.micro"

  # Security group
  vpc_security_group_ids = [aws_security_group.three-tier-ec2-asg-sg-app.id]

  # User Data script
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install mysql-server -y
    sudo systemctl start mysql.service
     EOF
  )

  lifecycle {
    #prevent_destroy = true
    ignore_changes = all
  }
}

