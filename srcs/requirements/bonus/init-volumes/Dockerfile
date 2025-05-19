FROM debian:bullseye

COPY --chmod=700 ./tools/init_volumes.sh /root/init_volumes.sh

WORKDIR /var/www/html

ENTRYPOINT [ "/root/init_volumes.sh" ]