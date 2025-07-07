# Exam Infrastructure Deployment

This repository contains Terraform configurations to deploy a highly-available WordPress application on both AWS and GCP, using free-tier eligible resources where possible.

## Structure

- `Task 1/AWS/` — AWS infrastructure (VPC, subnets, EC2, RDS, ALB)
[Watch Demo on Google Drive](https://drive.google.com/file/d/1K4NuWXlgigje9rzp4P7X8UutlVW23Hqt/view?usp=share_link)
- `Task 1/GCP/` — GCP infrastructure (VPC, subnets, Compute Engine, Cloud SQL)
[Watch Demo on Google Drive](https://drive.google.com/file/d/1Otp-Nm19v4qG3rH_irhaBfKzMidQK_9U/view?usp=share_link)

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- AWS CLI and/or GCP SDK installed and configured
- Appropriate credentials for AWS and/or GCP

---

## Deployment Instructions

### AWS

1. **Navigate to the AWS directory:**
   ```sh
   cd "Task 1/AWS"
   ```
2. **Initialize Terraform:**
   ```sh
   terraform init
   ```
3. **Set required variables:**
   - Edit `terraform.tfvars` and provide values for `db_password` and `key_name` (your EC2 SSH key pair name).
4. **Plan the deployment:**
   ```sh
   terraform plan
   ```
5. **Apply the configuration:**
   ```sh
   terraform apply
   ```
6. **Access WordPress:**
   - After deployment, find the DNS name of the ALB in the Terraform outputs or AWS Console.
   - Open it in your browser to access WordPress.

### GCP

1. **Navigate to the GCP directory:**
   ```sh
   cd "Task 1/GCP"
   ```
2. **Initialize Terraform:**
   ```sh
   terraform init
   ```
3. **Set required variables:**
   - Edit `terraform.tfvars` and provide values for `project_id`, `region`, `zone`, and `db_password`.
4. **Plan the deployment:**
   ```sh
   terraform plan
   ```
5. **Apply the configuration:**
   ```sh
   terraform apply
   ```
6. **Access WordPress:**
   - After deployment, find the external IP of the Compute Engine VM in the Terraform outputs or GCP Console.
   - Open it in your browser to access WordPress.

---

## Design Rationale

### AWS
- **VPC & Subnets:** Custom VPC with public subnets for ALB/EC2 and private subnets for RDS, ensuring database is not publicly accessible.
- **Security Groups:** Principle of least privilege; RDS only accessible from EC2, ALB open to HTTP, EC2 open to HTTP/SSH.
- **RDS:** MySQL 8, private, free-tier eligible, with subnet group for high availability.
- **EC2:** Ubuntu 24.04 LTS, installs WordPress via cloud-init, connects to RDS.
- **ALB:** Provides scalable, highly-available HTTP access to WordPress.
- **Tagging:** All resources are tagged for environment and identification.

### GCP
- **VPC & Subnet:** Custom VPC and subnet for isolation and control.
- **Private Services Access:** Cloud SQL uses private IP, not exposed to the public internet.
- **Cloud SQL:** MySQL 8, always-free tier, private IP, backup enabled.
- **Compute Engine:** Debian VM, startup script installs WordPress and connects to Cloud SQL.
- **Firewall:** Only HTTP and SQL traffic allowed as needed.
- **Labels:** Applied to supported resources for organization.

---

## Cleanup
To destroy all resources:
```sh
terraform destroy
```
Run this in each cloud's directory as needed.

---

## Notes
- Use strong passwords for database credentials.
- Ensure you have the necessary IAM permissions in your cloud accounts.

---

## Author
- Tharusha Kudagala Infrastructure as Code for Exam — July 2025
