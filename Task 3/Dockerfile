FROM wordpress:php8.2-apache

# Install MySQLi extension
RUN docker-php-ext-install mysqli

# Copy custom wp-content (optional)
COPY ./wp/wp-content /var/www/html/wp-content

# Set permissions (optional)
RUN chown -R www-data:www-data /var/www/html/wp-content

# Cloud Run uses port 8080
ENV PORT=8080
RUN sed -i "s/80/\${PORT}/" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 8080
