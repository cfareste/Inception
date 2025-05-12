FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 777 /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "tail", "-f", "/dev/null" ]