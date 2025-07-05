FROM wordpress:php8.2-apache

RUN docker-php-ext-install mysqli

COPY ./wp/wp-content /var/www/html/wp-content

RUN chown -R www-data:www-data /var/www/html/wp-content

ENV PORT=8080
RUN sed -i "s/80/\${PORT}/" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 8080
