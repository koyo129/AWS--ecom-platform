# 1. Load Balancer Configuration
resource "aws_lb" "app" {
  name               = "main-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_c.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "app-target-group"
  port     = 80
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

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional" 
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(hostname -I | awk '{print $1}')
cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body style="background-color:#2563eb; color:white; text-align:center; font-family:sans-serif;">
    <h1>CloudCommerce is LIVE</h1>
    <p>Instance ID: $INSTANCE_ID</p>
    <p>AZ: $AZ</p>
</body>
</html>
HTML
EOF
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
