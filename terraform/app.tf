# 1. Load Balancer Configuration
resource "aws_lb" "app" {
  name               = "main-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_c.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "app-target-group"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path    = "/"
    matcher = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# 2. Launch Template Configuration
resource "aws_launch_template" "web" {
  name_prefix            = "web-blueprint-"
  image_id               = "ami-0d52744d6551d851e"
  instance_type          = "t2.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
  name = aws_iam_instance_profile.ec2_profile.name
}

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = base64encode(<<-SCRIPT
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip git postgresql-client
pip3 install flask psycopg2-binary
git clone https://github.com/koyo129/AWS--ecom-platform.git /home/ubuntu/app
cd /home/ubuntu/app

export DB_HOST="${aws_db_instance.postgres.address}"
export DB_NAME="shopdb"
export DB_USER="${var.db_username}"
export DB_PASS="${var.db_password}"

# Table
PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.postgres.address}" -U "${var.db_username}" -d shopdb -c "CREATE TABLE IF NOT EXISTS products (id SERIAL PRIMARY KEY, name VARCHAR(100), price NUMERIC);"

# Gym products
PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.postgres.address}" -U "${var.db_username}" -d shopdb -c "INSERT INTO products (name, price) SELECT 'Whey Protein', 45 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Whey Protein');"
PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.postgres.address}" -U "${var.db_username}" -d shopdb -c "INSERT INTO products (name, price) SELECT 'Dumbbells', 120 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Dumbbells Set');"
PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.postgres.address}" -U "${var.db_username}" -d shopdb -c "INSERT INTO products (name, price) SELECT 'Resistance Bands', 25 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Resistance Bands');"
PGPASSWORD="${var.db_products}" psql -h "${aws_db_instance.postgres.address}" -U "${var.db_username}" -d shopdb -c "INSERT INTO products (name, price) SELECT 'Pre-Workout', 35 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Pre-Workout');"
PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.postgres.address}" -U "${var.db_username}" -d shopdb -c "INSERT INTO products (name, price) SELECT 'Lifty Factory shirts', 15 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Gym Gloves');"

DB_HOST="${aws_db_instance.postgres.address}" \
DB_NAME="shopdb" \
DB_USER="${var.db_username}" \
DB_PASS="${var.db_password}" \
python3 ecommerce.py &
SCRIPT
  )
}

# 3. Auto Scaling Group Configuration
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
  }

  tag {
    key                 = "Name"
    value               = "CloudCommerce-Web"
    propagate_at_launch = true
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attach SSM policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_role.name
}
