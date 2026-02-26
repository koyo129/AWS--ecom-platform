# AWS--ecom-platform

A Terraform-managed web infrastructure for a web page, featuring self-healing capabilities and automated load balancing.

## Features
* **Auto Scaling:** Maintains 2 EC2 instances across multiple Availability Zones.
* **Load Balancing:** Use ALB to distribute traffic and handle health checks.
* **Infrastructure as Code:** Terraform
* **Self-Healing:** Testedto replace terminated instances
* **CI/CD** Automated through GitHub Actions

## Challenges & Troubleshooting
During this project, I encountered and solved several challenges:

1. **Script Compatibility:** Encountered a 503 error initially because the script used `yum` on an Ubuntu-based AMI.
2. **State Management:** Faced an "Invalid target address" error when trying to replace a resource that had been removed from the state. I learned to use `terraform state list` to audit the environment before executing specific target commands.
3. **Infrastructure Debugging 502 gateawy:** Identified that instances in private subnets could not download Apache without a NAT Gateway route. Diagnosed using Target Group Health Checks and corrected the routing table to ensure successful initialization


<img width="1117" height="571" alt="Screenshot 2026-02-22 210421" src="https://github.com/user-attachments/assets/37cff391-875e-4477-8b8f-ed4b02d918f7" />

<img width="1110" height="624" alt="Screenshot 2026-02-22 210354" src="https://github.com/user-attachments/assets/67e619e2-c9ad-42e3-ac9f-c8ccc95c024f" />


## Future Improvements
- [ ] **Security:** Implement SSL/TLS certificates with ACM (buy dns)
- [ ] **Data:** Add an RDS PostgreSQL database to handle product inventory.
- [ ] **Security:** Improve frontend design and add backend functions

NEW UPDATE!!
- Implemented CI/CD through Github actions, PR.
- Created script to automate infrastructure deployment
- Pull Request (PR) triggers a terraform plan for code review, and merging to main executes for terraform apply
