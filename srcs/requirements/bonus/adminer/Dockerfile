FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates php-fpm php-mysqli curl

COPY ./conf/adminer_pool.conf /etc/php/7.4/fpm/pool.d/adminer.conf

RUN curl -L -o /root/adminer.php https://github.com/vrana/adminer/releases/download/v5.3.0/adminer-5.3.0.php

RUN mkdir -p /run/php && \
    chmod 777 /run/php

COPY --chmod=700 ./tools/init_adminer.sh /root/

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/root/init_adminer.sh" ]
CMD [ "php-fpm7.4", "-F" ]