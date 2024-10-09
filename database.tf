#### RDS ####
resource "aws_db_subnet_group" "three-tier-db-sub-grp" {
  name       = "three-tier-db-sub-grp"
  subnet_ids = ["${aws_subnet.three-tier-pvt-sub-3.id}", "${aws_subnet.three-tier-pvt-sub-4.id}"]
}

# security group
# Create Security Group for RDS Instance
resource "aws_security_group" "three-tier-db-sg" {
  name        = "three-tier-db-sg"
  description = "Security group for the RDS instance"
  vpc_id      = aws_vpc.three-tier-vpc.id

  # Allow inbound MySQL traffic from the Application Tier security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-ec2-asg-sg-app.id] # Reference the App Tier security group
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-db-sg"
  }
}


# RDS database instance
resource "aws_db_instance" "three-tier-db" {
  allocated_storage      = 100
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0.39"
  instance_class         = "db.t4g.micro"
  identifier             = "three-tier-db"
  username               = "admin"
  password               = "23vS5TdDW8*o"
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.three-tier-db-sub-grp.name
  vpc_security_group_ids = [aws_security_group.three-tier-db-sg.id]
  multi_az               = false
  skip_final_snapshot    = true
  publicly_accessible    = false

  lifecycle {
    # prevent_destroy = true
    ignore_changes = all
  }
}

