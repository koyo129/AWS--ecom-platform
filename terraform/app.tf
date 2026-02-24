# 1. Load Balancer Configuration

# Testing
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CloudCommerce | Premium Tech</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-950 text-gray-100 font-sans antialiased">

    <nav class="border-b border-gray-800 bg-gray-900/50 backdrop-blur-md sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center font-bold">C</div>
                <span class="text-xl font-bold tracking-tight">Cloud<span class="text-blue-500">Commerce</span></span>
            </div>
            <div class="hidden md:flex gap-8 text-sm font-medium text-gray-400">
                <a href="#" class="hover:text-white transition">Processors</a>
                <a href="#" class="hover:text-white transition">Storage</a>
                <a href="#" class="hover:text-white transition">Networking</a>
            </div>
            <button class="bg-blue-600 hover:bg-blue-700 px-5 py-2 rounded-full text-sm font-semibold transition">Cart (0)</button>
        </div>
    </nav>

    <header class="max-w-7xl mx-auto px-6 py-20 text-center">
        <h1 class="text-5xl md:text-7xl font-extrabold mb-6 bg-gradient-to-r from-white to-gray-500 bg-clip-text text-transparent">
            Next-Gen Infrastructure.
        </h1>
        <p class="text-gray-400 text-lg md:text-xl max-w-2xl mx-auto mb-10">
            High-performance cloud components delivered at the speed of light. Scalable, reliable, and elegant.
        </p>
        <div class="flex justify-center gap-4">
            <button class="bg-white text-black px-8 py-3 rounded-lg font-bold hover:bg-gray-200 transition">Shop Series 9</button>
            <button class="border border-gray-700 px-8 py-3 rounded-lg font-bold hover:bg-gray-900 transition">Learn More</button>
        </div>
    </header>

    <section class="max-w-7xl mx-auto px-6 py-12">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="bg-gray-900 border border-gray-800 p-6 rounded-2xl hover:border-blue-500/50 transition group">
                <div class="h-48 bg-gray-800 rounded-xl mb-6 flex items-center justify-center text-5xl group-hover:scale-105 transition">⚡</div>
                <h3 class="text-xl font-bold mb-2">Compute Core v4</h3>
                <p class="text-gray-400 text-sm mb-4">Ultra-low latency processing for modern workloads.</p>
                <div class="flex justify-between items-center">
                    <span class="text-xl font-bold font-mono">$299.00</span>
                    <button class="text-blue-500 font-semibold hover:underline">Add +</button>
                </div>
            </div>
            <div class="bg-gray-900 border border-gray-800 p-6 rounded-2xl hover:border-blue-500/50 transition group">
                <div class="h-48 bg-gray-800 rounded-xl mb-6 flex items-center justify-center text-5xl group-hover:scale-105 transition">💾</div>
                <h3 class="text-xl font-bold mb-2">Neural Storage</h3>
                <p class="text-gray-400 text-sm mb-4">Persistent memory with 99.999% durability.</p>
                <div class="flex justify-between items-center">
                    <span class="text-xl font-bold font-mono">$150.00</span>
                    <button class="text-blue-500 font-semibold hover:underline">Add +</button>
                </div>
            </div>
            <div class="bg-gray-900 border border-gray-800 p-6 rounded-2xl hover:border-blue-500/50 transition group">
                <div class="h-48 bg-gray-800 rounded-xl mb-6 flex items-center justify-center text-5xl group-hover:scale-105 transition">🌐</div>
                <h3 class="text-xl font-bold mb-2">Edge Gateway</h3>
                <p class="text-gray-400 text-sm mb-4">Global connectivity with zero-trust security.</p>
                <div class="flex justify-between items-center">
                    <span class="text-xl font-bold font-mono">$89.00</span>
                    <button class="text-blue-500 font-semibold hover:underline">Add +</button>
                </div>
            </div>
        </div>
    </section>

    <footer class="mt-20 border-t border-gray-800 bg-gray-900/30 py-8">
        <div class="max-w-7xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-4 text-xs font-mono text-gray-500">
            <div class="flex gap-4">
                <span>STATUS: <span class="text-green-500">OPERATIONAL</span></span>
                <span>ID: <span class="text-gray-300">$INSTANCE_ID</span></span>
                <span>AZ: <span class="text-gray-300">$AZ</span></span>
            </div>
            <p>&copy; 2026 CloudCommerce. Powered by AWS Auto Scaling.</p>
        </div>
    </footer>

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
