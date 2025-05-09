# Inception
A small application infrastructure using Docker and Docker compose

# MariaDB
https://github.com/MariaDB/mariadb-docker/blob/2d5103917774c4c53ec6bf3c6fdfc7b210e85690/11.8/Dockerfile
AND Executing a simple Dockerfile with mariadb and seeing what's wrong:
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

ENTRYPOINT ["mariadbd"]
~~~
MARIADB-SERVER => Program with all the database management (the only one needed)
MARIADB-CLIENT => CLI program with a SQL syntax shell to interact with the server
https://mariadb.com/kb/en/mariadb-client/

This doesn't work. On docker logs, you can read that you need this:
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

RUN mkdir -p /run/mysqld && \
   chown mysql:mysql /run/mysqld && \
   chmod 777 /run/mysqld

ENTRYPOINT ["mariadbd"]
~~~
Why: https://superuser.com/questions/980841/why-is-mysqld-pid-and-mysqld-sock-missing-from-my-system-even-though-the-val
/var/run is a symlink to /run in modern OS, so the mysqld directory should be under /run (ls -la /var/run)
/run is a tmpfs (mounted on the RAM) folder that stores runtime-files, so everytime mariadbd is executed it stores its files there
