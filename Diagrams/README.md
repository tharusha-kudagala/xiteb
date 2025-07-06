
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

### Prepared By Tharusha Kudagala
