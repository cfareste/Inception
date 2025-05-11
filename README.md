# Inception
A small application infrastructure using Docker and Docker compose

# MariaDB
https://github.com/MariaDB/mariadb-docker/blob/2d5103917774c4c53ec6bf3c6fdfc7b210e85690/11.8/Dockerfile <br/>
AND Executing a simple Dockerfile with mariadb and seeing what's wrong:
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

ENTRYPOINT ["mariadbd"]
~~~
MARIADB-SERVER => Program with all the database management (the only one needed) <br/>
MARIADB-CLIENT => CLI program with a SQL syntax shell to interact with the server

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
Why: https://superuser.com/questions/980841/why-is-mysqld-pid-and-mysqld-sock-missing-from-my-system-even-though-the-val <br/>
/var/run is a symlink to /run in modern OS, so the mysqld directory should be under /run (ls -la /var/run) <br/>
/run is a tmpfs (mounted on the RAM) folder that stores runtime-files, so everytime mariadbd is executed it stores its files there


## Config file
Why are there so many configuration folders?: <br/>
https://mariadb.com/kb/en/configuring-mariadb-with-option-files/ <br/>
https://www.baeldung.com/linux/mysql-find-my-cnf-command-line <br/>
AND Executing a simple Dockerfile with mariadb and read all the configuration files in /etc/mysql (/etc/mysql/*)

When you install MariaDB, every tool installed named mysql... is a symlink to its version of mariadb (configuration, binaries...) <br/>
https://mariadb.com/kb/en/mysql_secure_installation/ <br/>
https://mariadb.com/kb/en/mysql_install_db/

### Why is it called 50-server.cnf
50: Load order (if you have a 10-server.cnf, some of its configuration may be overriden by 50-server.cnf, as its loaded later) <br/>
Server: Arbitrary name, you can name it as you want (but it should make sense) <br/>
https://askubuntu.com/questions/1271400/unknown-variable-pid-file-run-mysqld-mysqld-pid-when-setting-50-server-cnf

### Server system variables
https://mariadb.com/kb/en/server-system-variables/#basedir

### Character-encoding config
https://stackoverflow.com/questions/30074492/what-is-the-difference-between-utf8mb4-and-utf8-charsets-in-mysql <br/>
https://stackoverflow.com/questions/766809/whats-the-difference-between-utf8-general-ci-and-utf8-unicode-ci <br/>

### Failed to configure mariadb without writting "user" variable in mariadb.conf
It tries to execute mariadbd as root and fails <br/>
https://stackoverflow.com/questions/25700971/fatal-error-please-read-security-section-of-the-manual-to-find-out-how-to-run

After configuration:
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

ENTRYPOINT [ "mariadbd" ]
~~~


## Where does MariaDB saves its databases as default (storage directory)
https://mariadb.com/kb/en/default-data-directory-for-mariadb/


## MariaDB Server and Client differences
mariadbd: server (daemon process that manages all the databases) <br/>
mariadb: client (CLI program that gives you a SQL shell to interact with the server via queries) <br/>
https://mariadb.com/docs/server/connect/clients/mariadb-client/

Why do we have mariadb installed?: Because its impossible to interact with the server (and databases) without one. The package
mariadb-server depends on mariadb-client, so it's installed at the same time. <br/>
Proof: apt show mariadb-server and then apt show mariadb-server-x.x.x (the version that appears in DEPENDS)


## MariaDB system databases
https://mariadb.com/kb/en/understanding-mariadb-architecture/ <br/>
https://mariadb.com/kb/en/the-mysql-database-tables/ <br/>
https://mariadb.com/kb/en/use-database/


## What should you do after installing mariadb-server package?
After installing the package and successfully configuring it with 50-server.cnf: <br/>
https://greenwebpage.com/community/how-to-install-mariadb-on-ubuntu-24-04/ <br/>
https://mariadb.com/kb/en/mariadb-install-db/

But, it is necessary to run mariadb-install-db if you already have a working datadir and system databases? NO: <br/>
https://serverfault.com/questions/1015287/is-mysql-install-db-needed-to-install-mariadb

But mariadb-secure-installation it's still recommended as it's for security concerns, so: <br/>
https://mariadb.com/kb/en/mariadb-secure-installation/ <br/>
https://mariadb.org/authentication-in-mariadb-10-4/


## Creating the script init_mariadb.sh
### Mariadb secure installation
1. Install the secure policies:
~~~
install_secure_policies()
{
	mariadb-secure-installation <<- _EOF_

		y
		y
		$MARIADB_ROOT_PASSWORD
		$MARIADB_ROOT_PASSWORD
		y
		y
		y
		y
	_EOF_
}

install_secure_policies
mariadbd
~~~
2. Copying it to eh /root folder
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/init_mariadb.sh /root

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

ENTRYPOINT [ "/root/init_mariadb.sh" ]
~~~
3. Can't execute the container due to permission denied (missing execution permissions)
~~~
COPY --chmod=700 ./tools/init_mariadb.sh /root
~~~
4. Doesn't work because it cannot establish connection, as the socket is not initialized. To do so, we need to enable the service:
https://discourse.ubuntu.com/t/mariadb-error-2002-hy000-cant-connect-to-local-server-through-socket-run-mysqld-mysqld-sock-2/53941 <br/>
https://discourse.ubuntu.com/t/mariadb-error-2002-hy000-cant-connect-to-local-server-through-socket-run-mysqld-mysqld-sock-2/53941
~~~
[...]

service mariadb start
install_secure_policies
service mariadb stop
mariadbd
~~~
5. Now doesn't work because mariadb-secure-installation expects a tty and not a heredoc. So we need to do the operations manually:
https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script <br/>
and going to mariadb container and doing cat /usr/bin/mariadb-secure-installation, copying the queries <br/>
final result:
~~~
intialize_service()
{
    service mariadb start
    sleep 1
}

install_secure_policies()
{
    # Set the root new password
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$MARIADB_ROOT_PASSWORD');"

    # Remove anonymous users
    mariadb -e "DELETE FROM mysql.user WHERE User='';"
    
    # Disallow remote root login
    mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    
    # Remove test database and privileges on this database
    mariadb -e "DROP DATABASE IF EXISTS test;"
    mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

    # Reload privilege tables
    mariadb -e "FLUSH PRIVILEGES;"
}

intialize_service
install_secure_policies
service mariadb stop

mariadbd
~~~

