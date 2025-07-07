# Task 1 - WordPress Deployment to EC2 with ALB and RDS (AWS)


This architecture deploys a basic WordPress setup using Amazon EC2, RDS (MySQL), and Application Load Balancer (ALB) within a VPC spanning multiple Availability Zones.

![EC2 Architecture](https://github.com/tharusha-kudagala/xiteb/blob/main/Diagrams/Task%201%20-%20AWS.png?raw=true)

## 🧩 Architecture Components

### 1. **VPC: `main`**
- A logically isolated section of AWS Cloud hosting all components.

### 2. **Subnets**
- **Public Subnet AZ1-1 & AZ2-1**: 
  - Hosts ALB and EC2 (WordPress).
  - Connected to the Internet Gateway.
- **Private Subnet AZ1 & AZ2**:
  - Hosts the RDS MySQL instance.

### 3. **Compute**
- **EC2 Instance (WordPress)**:
  - Placed in a public subnet for web access.
  - Receives HTTP traffic from ALB.
  - SSH access (Port 22) enabled.

### 4. **Database**
- **Amazon RDS (MySQL)**:
  - Located in private subnets across two AZs for high availability.
  - Receives traffic only from EC2 instances.

### 5. **Load Balancing**
- **Application Load Balancer (ALB)**:
  - Distributes incoming HTTP traffic across EC2 instances.
  - Deployed in public subnets.

### 6. **Internet Gateway**
- Provides internet access to public subnets and enables EC2 to download packages.


## 🔐 Security Groups

| Component | Rules |
|----------|--------|
| **SG: ALB** | Allow HTTP from anywhere (0.0.0.0/0) |
| **SG: EC2** | Allow HTTP from ALB, SSH from your IP |
| **SG: RDS** | Allow MySQL (port 3306) from EC2 |


## 🔄 Flow Overview

1. **User → ALB → EC2** (HTTP)
2. **EC2 → RDS** (MySQL)
3. **Admin → EC2** (SSH)
4. **EC2 → Internet** (via IGW, for updates)

---
# Task 1 - WordPress Deployment to Compute Engine with Cloud SQL (Private IP) (GCP)

This project sets up a basic WordPress deployment on Google Cloud Platform (GCP) using a Compute Engine instance and Cloud SQL (MySQL) with private IP connectivity via VPC peering.

![Compute Engine Architecture](https://github.com/tharusha-kudagala/xiteb/blob/main/Diagrams/Task%201%20-%20GCP.png?raw=true)

## 🧩 Architecture Overview

### 1. **VPC: `wp-vpc`**
- The main Virtual Private Cloud hosting the WordPress VM and peered to the SQL network.

### 2. **Compute Engine**
- **Instance**: `wordpress-vm`
- **Machine Type**: `f1-micro` (Free Tier eligible)
- **Function**: Hosts the WordPress application
- **Access**: HTTP (port 80) allowed from anywhere (0.0.0.0/0)

### 3. **Cloud SQL**
- **Instance**: `wp-sql`
- **Version**: MySQL 8.0
- **IP Type**: Private IP only (for better security)
- **Connectivity**: Via VPC peering using a designated IP range


## 🔐 Firewall Rules

| Rule Name        | Port         | Source            | Purpose                    |
|------------------|--------------|--------------------|----------------------------|
| `allow-http`     | TCP 80       | `0.0.0.0/0`        | Allow HTTP traffic to VM   |
| `allow-sql-egress` | TCP 3306   | `172.18.0.0/16`    | Allow SQL egress from VM   |


## 🔗 VPC Peering

| Component            | Detail                        |
|----------------------|-------------------------------|
| **Peering Range**    | `sql-private-range` (`172.x.x.x`) |
| **Subnet**           | `10.10.1.0/24` (Public subnet)     |
| **Purpose**          | Enables private IP communication between the Compute Engine and Cloud SQL instance |

## 🔄 Data Flow

1. **Internet** → HTTP request to port 80 → `wordpress-vm`
2. `wordpress-vm` → SQL connection on port 3306 → `wp-sql`
3. `wp-sql` → responds via private IP over VPC peering

---

# Task 3 – WordPress Deployment to Cloud Run (GCP)

This task demonstrates deploying a containerized WordPress application to **Google Cloud Run** using **GitHub Actions** for CI/CD.

## 🛠️ Architecture Overview

The workflow follows the below architecture:

![Cloud Run Architecture](https://github.com/tharusha-kudagala/xiteb/blob/main/Diagrams/Task%203%20-%20Cloud%20Run.png?raw=true)

### 🔄 Workflow Steps:
1. **GitHub Actions** triggers the pipeline on code push.
2. Docker image is built and **pushed to Google Artifact Registry**.
3. The image is **deployed to Cloud Run**.
4. The application connects to:
   - **Cloud SQL** (for database)
   - **Cloud Storage** (for storing static files like media uploads)

## 📁 Files Included
- `main.tf`: Terraform code to provision Cloud Run, SQL, and Storage.
- `Dockerfile`: Custom WordPress Docker image.
- `GitHub Actions workflow`: Automates deployment from GitHub to GCP.

## 🌐 Services Used
- **Cloud Run**
- **Cloud SQL**
- **Cloud Storage**
- **Artifact Registry**
- **GitHub Actions**

---

### Tharusha Kudagala
