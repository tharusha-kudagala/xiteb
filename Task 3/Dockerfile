FROM bitnami/wordpress:latest

# Copy your custom wp-content to a temporary location
COPY ./wp/wp-content /custom-wp-content

# Temporarily switch to root user
USER root

# Copy the custom entrypoint and make it executable
COPY custom-entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

# Switch back to Bitnami's default non-root user
USER 1001

# Use the custom entrypoint which injects wp-content at runtime
ENTRYPOINT ["/custom-entrypoint.sh"]
