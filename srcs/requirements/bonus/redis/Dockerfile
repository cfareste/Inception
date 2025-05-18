FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends redis-server

COPY ./conf/redis_cache.conf /etc/redis/inception/inception.conf

EXPOSE 6379

ENTRYPOINT [ "redis-server", "/etc/redis/inception/inception.conf" ]