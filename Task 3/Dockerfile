# FROM wordpress:php8.2-apache

# # Copy custom wp-content if you have one
# COPY ./wp/wp-content /var/www/html/wp-content

# # Allow WordPress to read/write (optional if wp-content has strict perms)
# RUN chown -R www-data:www-data /var/www/html/wp-content

# # Cloud Run uses port 8080
# ENV PORT=8080
# RUN sed -i "s/80/\${PORT}/" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

# EXPOSE 8080

FROM php:8.1-apache

COPY index.php /var/www/html/index.php

EXPOSE 8080
