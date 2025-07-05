FROM bitnami/wordpress:latest

# Copy wp-content to the correct location in the container
COPY wp/wp-content /bitnami/wordpress/wp-content

ENV APACHE_HTTP_PORT_NUMBER=8080
EXPOSE 8080
