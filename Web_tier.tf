######### Create an EC2 Auto Scaling Group - web ############
resource "aws_autoscaling_group" "three-tier-web-asg" {
  name = "three-tier-web-asg"
  launch_template {
    id      = aws_launch_template.three-tier-web-template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2
}
############## AWS_security_group ####################
resource "aws_security_group" "three-tier-ec2-asg-sg" {
  name        = "three-tier-ec2-asg-sg"
  description = "It will akllow inbound traffic to the EC2 instances in the Auto Scaling Group"
  vpc_id      = aws_vpc.three-tier-vpc.id

  # Allow incoming traffic on HTTP port 80 and https 443
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "three-tier-ec2-asg-sg"
  }
}


###### Create a launch template for the EC2 instances #####
resource "aws_launch_template" "three-tier-web-template" {
  name_prefix   = "three-tier-web-template"
  image_id      = "ami-047126e50991d067b" #ubuntu ami id
  instance_type = "t2.micro"

  # vpc_security_group_ids = [aws_security_group.three-tier-ec2-asg-sg.id]
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.three-tier-ec2-asg-sg.id]
  }

  # User Data script for bootstrapping the EC2 instances
  user_data = base64encode(file("${path.module}/user_data.sh"))


  # give the Tags for the instancers
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web-instance"
    }
  }
}
