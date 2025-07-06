#!/bin/bash

echo "🔥 Step 1: Destroying Cloud SQL resources first..."
terraform destroy -auto-approve \
  -target=google_sql_database.wordpress \
  -target=google_sql_user.root_user \
  -target=google_sql_database_instance.mysql

echo "✅ Cloud SQL resources destroyed."

echo "⏳ Waiting a few seconds to allow VPC peering connection to clear..."
sleep 20

echo "🔥 Step 2: Destroying remaining infrastructure..."
terraform destroy -auto-approve

echo "🏁 All resources have been destroyed successfully."
