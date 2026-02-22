# Load Balancer
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

# Launch Template 
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CloudCommerce | Tech Store</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900 font-sans">
    <nav class="bg-white shadow-md p-4">
        <div class="container mx-auto flex justify-between items-center">
            <h1 class="text-2xl font-bold text-blue-600">CloudCommerce</h1>
            <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-semibold">Region: ap-northeast-1</span>
        </div>
    </nav>
    <div class="bg-yellow-100 border-b border-yellow-200 p-2 text-center text-xs font-mono text-yellow-800">
        Connected to: <strong>$INSTANCE_ID</strong> | IP: <strong>$PRIVATE_IP</strong> | AZ: <strong>$AZ</strong>
    </div>
    <header class="container mx-auto my-12 px-6">
        <div class="bg-blue-600 rounded-2xl p-10 text-white flex flex-col md:flex-row items-center justify-between">
            <div class="md:w-1/2">
                <h2 class="text-4xl font-extrabold mb-4">The Future of Cloud Computing is Here.</h2>
                <p class="mb-6 text-blue-100 italic">High Availability. Multi-AZ. Scalable Architecture.</p>
                <button class="bg-white text-blue-600 px-6 py-3 rounded-lg font-bold shadow-lg">Shop Now</button>
            </div>
            <div class="md:w-1/3 text-6xl"> ☁️ 🚀 </div>
        </div>
    </header>
</body>
</html>
HTML
EOF
  )
}

# Auto Scaling Group 
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
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "CloudCommerce-Web"
    propagate_at_launch = true
  }
}
