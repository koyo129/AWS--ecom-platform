# AWS--ecom-platform

A Terraform-managed web infrastructure for a web page, featuring self-healing capabilities and automated load balancing.

## Features
* **Auto Scaling:** Maintains 2 EC2 instances across multiple Availability Zones.
* **Load Balancing:** Use ALB to distribute traffic and handle health checks.
* **Infrastructure as Code:** Terraform
* **Self-Healing:** Testedto replace terminated instances 

## Challenges & Troubleshooting
During this project, I encountered and solved several challenges:

1. **Script Compatibility:** Encountered a 503 error initially because the bootstrap script used `yum` on an Ubuntu-based AMI. I updated the User Data to use `apt-get`, ensuring the web server initialized correctly.
2. **State Management:** Faced an "Invalid target address" error when trying to replace a resource that had been removed from the state. I learned to use `terraform state list` to audit the environment before executing specific target commands.
3. **Infrastructure Debugging:** Successfully identified a 502 Bad Gateway as a "warm-up" phase for new instances, learning to monitor Target Group Health Checks to verify deployment success.


<img width="1117" height="571" alt="Screenshot 2026-02-22 210421" src="https://github.com/user-attachments/assets/37cff391-875e-4477-8b8f-ed4b02d918f7" />

<img width="1110" height="624" alt="Screenshot 2026-02-22 210354" src="https://github.com/user-attachments/assets/67e619e2-c9ad-42e3-ac9f-c8ccc95c024f" />


## Future Improvements
- [ ] **Security:** Implement SSL/TLS certificates with ACM (buy dns)
- [ ] **Data:** Add an RDS PostgreSQL database to handle product inventory. (after frontend is done)
- [ ] **Security:** Improve frontend design and add backend functions

NEW UPDATE!!
- Implemented CI/CD through Github actions, PR.
- Created script to automate infrastructure deployment
- Pull Request (PR) triggers a terraform plan for code review, and merging to main executes for terraform apply
