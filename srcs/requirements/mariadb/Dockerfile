FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY --chmod=700 ./tools/init_mariadb.sh /root

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

EXPOSE 3306

ENTRYPOINT [ "bash", "/root/init_mariadb.sh" ]