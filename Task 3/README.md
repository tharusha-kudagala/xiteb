# 🚀 WordPress Docker Image – Task 3 (Cloud Run + Cloud SQL)

This Dockerfile builds a custom WordPress image tailored for deployment on **Google Cloud Run**, integrating with infrastructure provisioned in **Task 3** (Cloud SQL and optionally Cloud Storage via Terraform).

---

## ✅ What's Inside

- 🔧 Based on `wordpress:php8.2-apache`
- 🧩 Installs the `mysqli` PHP extension for MySQL compatibility
- 📂 Copies your custom `wp-content` (themes, plugins, uploads)
- 🔐 Sets proper ownership for WordPress to write files
- 🌐 Configures Apache to listen on port `8080` (required for Cloud Run)

---

## 📁 Folder Structure

Ensure the following structure:

```
.
├── Dockerfile
└── wp/
    └── wp-content/
        ├── themes/
        ├── plugins/
```

---

## 🛠️ Build Instructions

```bash
docker build -t my-wordpress:latest .
```

---

## ☁️ Deploy to Google Cloud Run

After pushing the image to Artifact Registry:

```bash
gcloud run deploy wp-cloudrun   --image us-central1-docker.pkg.dev/<PROJECT_ID>/wp-app/wordpress:latest   --region us-central1   --platform managed   --allow-unauthenticated   --project <PROJECT_ID>   --set-env-vars "WORDPRESS_DB_HOST=<CLOUDSQL_IP>,WORDPRESS_DB_NAME=<DB_NAME>,WORDPRESS_DB_USER=<DB_USER>,WORDPRESS_DB_PASSWORD=<DB_PASSWORD>,WORDPRESS_STORAGE=<STORAGE_BUCKET>"
```

---

## 📌 Notes

- Cloud SQL must allow connections from Cloud Run (public IP or VPC connector).
- This image includes `wp-content` at build time — update the folder before building.
- You can optionally configure Cloud Storage via plugin or custom logic.
- Ensure your `DB_PASSWORD` doesn’t include newlines when passed to env vars.

---

## 🔒 Security Tips

- Never hard-code credentials. Use secrets manager or CI/CD environment variables.
- Remove `0.0.0.0/0` from SQL authorized networks in production.

---

**Built for Task 3 - GCP DevOps Practical by [Tharusha Kudagala]**
