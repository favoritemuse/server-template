FROM php:8.0-apache
RUN apt-get update && apt-get install -y \
    libssl-dev nano cron
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN apt-get upgrade -y
RUN a2enmod rewrite
RUN mkdir -p /var/lib/php/sessions && chmod -R 777 /var/lib/php/sessions
RUN apt-get update && apt-get install -y msmtp ca-certificates
RUN /etc/init.d/cron start

COPY php.ini /usr/local/etc/php/php.ini
COPY apache.conf /etc/apache2/sites-available/000-default.conf