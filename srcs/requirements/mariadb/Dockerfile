FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

EXPOSE 3306

ENTRYPOINT [ "mariadbd" ]