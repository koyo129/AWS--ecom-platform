Updated 04/25/2026
# Lifty Factory — AWS 3-Tier E-Commerce Platform

<img width="624" height="172" alt="Screenshot 2026-04-25 at 22 52 43" src="https://github.com/user-attachments/assets/d71eb9d6-62c8-4c70-bf84-9df6efd8f91d" />


<img width="632" height="184" alt="Screenshot 2026-04-25 at 22 53 38" src="https://github.com/user-attachments/assets/32367614-854e-4331-b57d-f31074c81b17" />

<img width="631" height="316" alt="Screenshot 2026-04-25 at 22 54 15" src="https://github.com/user-attachments/assets/2d40322d-66d0-4e03-a98f-ab570feb65b5" />


A fully functional 3-tier e-commerce web application built on AWS,
managed entirely with Terraform

## BACK STORY

In my current work I perform operational maintenance 
for enterprise network equipments
Day to day this involves manually monitoring systems for issues, 
reacting quickly when problems occur, and resolving them by hand.

Over time I noticed several inefficiencies:
- Manual monitoring means problems are only caught when someone 
  notices them
- No automated recovery — every incident requires human intervention
- Repetitive manual tasks that could be automated
- Single points of failure with no redundancy

Because of these factors it made me think if there is a way to effectively improve
this system and workflow hence why I started learning cloud infrastructure and DevOps practices to 
understand how modern systems solve these exact problems:
- Automated alerting services
- Auto Scaling Groups replace manual instance recovery
- Infrastructure as Code replaces manual server configuration
- Multi-AZ architecture eliminates single points of failure

This project is my attempt to build the kind of reliable, 
automated, self-healing infrastructure for a webpage

## Architecture

- **Tier 1 — Presentation:** Application Load Balancer in public subnets
- **Tier 2 — Application:** EC2 instances running Python Flask in private subnets
- **Tier 3 — Database:** RDS PostgreSQL in private subnets

## Tech Stack

| Layer | Technology |
|---|---|
| Infrastructure | Terraform |
| Cloud | AWS Tokyo (ap-northeast-1) |
| Web Framework | Python Flask |
| Database | PostgreSQL on RDS |
| Load Balancer | AWS ALB |
| Monitoring | CloudWatch + SNS |
| CI/CD | GitHub Actions |

## Security

- EC2 in private subnets — not directly accessible from internet
- RDS in private subnets — only accessible from EC2 on port 5432
- Security groups with least privilege per layer

## High Availability

- Multi-AZ deployment across ap-northeast-1a and ap-northeast-1c
- Separate NAT Gateway per AZ — no single point of failure
- ASG automatically replaces unhealthy instances
- ALB health checks detect and route around failures
- RDS Multi-AZ with automatic failover

## Monitoring & Alerting

CloudWatch alarms trigger SNS email alerts for:
- EC2 CPU above 80%
- ALB 5xx error count above 10

## CI/CD Pipeline

- Pull Request → triggers `terraform plan` for code review
- Merge to main → triggers `terraform apply`
- Automated infrastructure deployment via GitHub Actions

## Testing & Validation

### Self-Healing Test 
Manually terminated an EC2 instance. The ALB automatically routed
traffic to the healthy instance with zero downtime. ASG detected
the missing instance and launched a replacement automatically.

### Load Test 
Used `hey` load testing tool to send 10,000 requests:
- 1,000 requests → 100% success rate
- 10,000 requests → 98.75% success rate (111 req/sec)
- Average response time: 410ms under normal load

## Terraform Files

| providers.tf | AWS provider + version config |
| storage.tf | S3 remote state backend |
| network.tf | VPC, subnets, IGW, NAT, route tables |
| security.tf | Security groups for ALB, EC2, RDS |
| app.tf | ALB, Launch Template, ASG, IAM |
| database.tf | RDS PostgreSQL instance |
| variables.tf | Input variables |
| outputs.tf | Website URL and RDS endpoint |
| monitoring.tf | CloudWatch alarms + SNS |

## Challenges & Troubleshooting

**1. Script Compatibility (503 error)**
Used `yum` package manager on an Ubuntu AMI which uses `apt-get`.
Fixed by switching to `apt-get` in user_data.

**2. NAT Gateway Routing (502 error)**
Private subnet EC2 instances couldn't reach internet to download
packages. Fixed by correctly associating private route tables
with NAT Gateway.

**3. Terraform State Mismatch**
Editing code after deployment caused state conflicts. Used
`terraform state list` and `terraform state rm` to resync state.

**4. Database Table Initialization**
RDS was provisioned but products table didn't exist. Solved by
adding `init_db()` function in Flask that automatically creates
the table and seeds data on startup.

## Future Improvements

- HTTPS with ACM certificate and custom domain(paid)
- Nginx as reverse proxy in front of Flask
- Dynamic auto scaling policies based on CPU
- S3 bucket for product images
- Redis/ElastiCache for session management
- DynamoDB state locking for team environments
