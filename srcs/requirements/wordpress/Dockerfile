FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli php-json php-redis

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && \
    chmod 777 /run/php

COPY ./conf/inception_pool.conf /etc/php/7.4/fpm/pool.d/inception.conf

COPY --chmod=700 ./tools/init_wordpress.sh /root/init_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/root/init_wordpress.sh" ]
