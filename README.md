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


## Config file
Why are there so many configuration folders?:
https://mariadb.com/kb/en/configuring-mariadb-with-option-files/
https://www.baeldung.com/linux/mysql-find-my-cnf-command-line
AND Executing a simple Dockerfile with mariadb and read all the configuration files in /etc/mysql (/etc/mysql/*)

When you install MariaDB, every tool installed named mysql... is a symlink to its version of mariadb (configuration, binaries...)
https://mariadb.com/kb/en/mysql_secure_installation/
https://mariadb.com/kb/en/mysql_install_db/

### Why is it called 50-server.cnf
50: Load order (if you have a 10-server.cnf, some of its configuration may be overriden by 50-server.cnf, as its loaded later)
Server: Arbitrary name, you can name it as you want (but it should make sense)
https://askubuntu.com/questions/1271400/unknown-variable-pid-file-run-mysqld-mysqld-pid-when-setting-50-server-cnf

### Server system variables
https://mariadb.com/kb/en/server-system-variables/#basedir

### Character-encoding config
https://stackoverflow.com/questions/30074492/what-is-the-difference-between-utf8mb4-and-utf8-charsets-in-mysql
https://stackoverflow.com/questions/766809/whats-the-difference-between-utf8-general-ci-and-utf8-unicode-ci

### Failed to configure mariadb without writting "user" variable in mariadb.conf
It tries to execute mariadbd as root and fails
https://stackoverflow.com/questions/25700971/fatal-error-please-read-security-section-of-the-manual-to-find-out-how-to-run



## Where does MariaDB saves its databases as default (storage directory)
https://mariadb.com/kb/en/default-data-directory-for-mariadb/
