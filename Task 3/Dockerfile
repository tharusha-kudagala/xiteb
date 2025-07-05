FROM bitnami/wordpress:latest

# Copy your custom wp-content to a temp folder
COPY ./wp/wp-content /custom-wp-content

# Copy custom entrypoint
COPY custom-entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

# Override entrypoint
ENTRYPOINT ["/custom-entrypoint.sh"]
