#!/bin/bash

echo "🌀 Waiting for WordPress files to be initialized..."
while [ ! -d /bitnami/wordpress/wp-content ]; do
  sleep 1
done

echo "✅ Copying custom wp-content..."
cp -r /custom-wp-content/* /bitnami/wordpress/wp-content/

# Run Bitnami's default entrypoint
exec /opt/bitnami/scripts/wordpress/entrypoint.sh /opt/bitnami/scripts/wordpress/run.sh
