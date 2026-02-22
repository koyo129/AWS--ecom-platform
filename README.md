# AWS--ecom-platform

A Terraform-managed web infrastructure for a web page, featuring self-healing capabilities and automated load balancing.

## Features
* **Auto Scaling:** Automatically maintains 2 EC2 instances across multiple Availability Zones.
* **Load Balancing:** Uses an Application Load Balancer (ALB) to distribute traffic and handle health checks.
* **Infrastructure as Code:** 100% automated deployment using Terraform.
* **Self-Healing:** Tested and verified to automatically replace terminated instances without downtime.

## Tech 
* **Cloud:** AWS (EC2, VPC, ALB, ASG, NAT Gateway)
* **IaC:** Terraform
* **OS:** Ubuntu 22.04 LTS
* **Web Server:** Apache2

## Challenges & Troubleshooting
During this project, I encountered and solved several challenges:

1. **Script Compatibility:** Encountered a 503 error initially because the bootstrap script used `yum` on an Ubuntu-based AMI. I updated the User Data to use `apt-get`, ensuring the web server initialized correctly.
2. **State Management:** Faced an "Invalid target address" error when trying to replace a resource that had been removed from the state. I learned to use `terraform state list` to audit the environment before executing specific target commands.
3. **Infrastructure Debugging:** Successfully identified a 502 Bad Gateway as a "warm-up" phase for new instances, learning to monitor Target Group Health Checks to verify deployment success.

## How to Deploy
1. Clone the repository.
2. Link AWS account through access and secret key.
3. Run `terraform init`.
4. Run `terraform plan`.
5. Run `terraform apply`.
6. Access the site via the output variable.


<img width="1110" height="624" alt="Screenshot 2026-02-22 210354" src="https://github.com/user-attachments/assets/67e619e2-c9ad-42e3-ac9f-c8ccc95c024f" /><img width="1117" height="571" alt="Screenshot 2026-02-22 210421" src="https://github.com/user-attachments/assets/37cff391-875e-4477-8b8f-ed4b02d918f7" />

<img width="1110" height="624" alt="Screenshot 2026-02-22 210354" src="https://github.com/user-attachments/assets/67e619e2-c9ad-42e3-ac9f-c8ccc95c024f" />


## Future Improvements
- [ ] **Security:** Implement SSL/TLS certificates via AWS Certificate Manager (ACM)
- [ ] **Data:** Add an RDS PostgreSQL database to handle product inventory. (after frontend is done)
- [ ] **Automation:** Integrate GitHub Actions for a full CI/CD pipeline.
- [ ] **Security:** Improve frontend design and add backend functions
