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
    path = "/"
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

# Launch Template (The Blueprint)
resource "aws_launch_template" "web" {
  name_prefix   = "web-blueprint-"
  image_id      = "ami-0d52744d6551d851e"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional" 
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
# Install Apache
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Instance ID and IP 
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Ecom
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CloudCommerce | Tech Store</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900 font-sans">

    <nav class="bg-white shadow-md p-4">
        <div class="container mx-auto flex justify-between items-center">
            <h1 class="text-2xl font-bold text-blue-600">CloudCommerce</h1>
            <div class="space-x-6 text-gray-600">
                <a href="#" class="hover:text-blue-500">Products</a>
                <a href="#" class="hover:text-blue-500">Cart</a>
                <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-semibold">
                    Region: ap-northeast-1
                </span>
            </div>
        </div>
    </nav>

    <div class="bg-yellow-100 border-b border-yellow-200 p-2 text-center text-xs font-mono text-yellow-800">
        Connected to: <strong>$INSTANCE_ID</strong> | IP: <strong>$PRIVATE_IP</strong> | AZ: <strong>$AZ</strong>
    </div>

    <header class="container mx-auto my-12 px-6">
        <div class="bg-blue-600 rounded-2xl p-10 text-white flex flex-col md:flex-row items-center justify-between">
            <div class="md:w-1/2">
                <h2 class="text-4xl font-extrabold mb-4">The Future of Cloud Computing is Here.</h2>
                <p class="mb-6 text-blue-100 italic italic">High Availability. Multi-AZ. Scalable Architecture.</p>
                <button class="bg-white text-blue-600 px-6 py-3 rounded-lg font-bold shadow-lg hover:bg-gray-100 transition">Shop Now</button>
            </div>
            <div class="md:w-1/3 mt-8 md:mt-0 text-6xl"> ☁️ 🚀 </div>
        </div>
    </header>

    <main class="container mx-auto px-6 mb-20">
        <h3 class="text-2xl font-bold mb-8 italic">Featured Infrastructure Packages</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="bg-white rounded-xl shadow-sm border p-4 hover:shadow-md transition">
                <div class="h-40 bg-gray-200 rounded-lg mb-4 flex items-center justify-center text-4xl"> 💻 </div>
                <h4 class="font-bold text-lg">Cloud Compute Pro</h4>
                <p class="text-gray-500 text-sm mb-4">Unlimited EC2 cycles with high redundancy.</p>
                <div class="flex justify-between items-center font-bold">
                    <span>¥49,900</span>
                    <button class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">Add to Cart</button>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border p-4 hover:shadow-md transition">
                <div class="h-40 bg-gray-200 rounded-lg mb-4 flex items-center justify-center text-4xl"> 📦 </div>
                <h4 class="font-bold text-lg">Storage Master S3</h4>
                <p class="text-gray-500 text-sm mb-4">Scalable object storage for your assets.</p>
                <div class="flex justify-between items-center font-bold">
                    <span>¥12,500</span>
                    <button class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">Add to Cart</button>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border p-4 hover:shadow-md transition">
                <div class="h-40 bg-gray-200 rounded-lg mb-4 flex items-center justify-center text-4xl"> 🔐 </div>
                <h4 class="font-bold text-lg">IAM Security Bundle</h4>
                <p class="text-gray-500 text-sm mb-4">Roles, Policies, and MFA management.</p>
                <div class="flex justify-between items-center font-bold">
                    <span>¥8,000</span>
                    <button class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">Add to Cart</button>
                </div>
            </div>
        </div>
    </main>

    <footer class="text-center py-10 text-gray-400 text-sm border-t">
    </footer>

</body>
</html>
EOF
  )
}

# Auto Scaling Group (The Manager)
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
}
