# Inception
A small application infrastructure using Docker and Docker compose

# PID 1 in docker
https://github.com/antontkv/docker-and-pid1

# How does Nginx + php-fpm + WordPress ecosystem works
What really is wordpress and how it works: https://en.wikipedia.org/wiki/WordPress <br/>
Wordpress builds only dynamic websites: https://www.liquidweb.com/wordpress/php/ <br/>
How nginx works with php-fpm to return static AND dynamic websites: https://www.sitepoint.com/lightning-fast-wordpress-with-php-fpm-and-nginx/ <br/>
How does wordpress, php-fpm and nginx work together: https://flywp.com/blog/9281/optimize-php-fpm-settings-flywp/ <br/>
PHP workers: https://spinupwp.com/doc/how-php-workers-impact-wordpress-performance/ <br/>
Differences between CGI, FastCGI and FPM: <br/>
1. https://help.quickhost.uk/index.php/knowledge-base/whats-the-difference-between-cgi-dso-suphp-and-lsapi-php <br/>
2. https://serverfault.com/questions/645755/differences-and-dis-advanages-between-fast-cgi-cgi-mod-php-suphp-php-fpm <br/>
3. https://www.basezap.com/difference-php-cgi-php-fpm/

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
#! /bin/bash

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
2. Copying it to the /root folder
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
4. Doesn't work because it cannot establish connection, as the socket is not initialized. To do so, we need to enable the service: <br/>
https://discourse.ubuntu.com/t/mariadb-error-2002-hy000-cant-connect-to-local-server-through-socket-run-mysqld-mysqld-sock-2/53941 <br/>
https://discourse.ubuntu.com/t/mariadb-error-2002-hy000-cant-connect-to-local-server-through-socket-run-mysqld-mysqld-sock-2/53941
~~~
[...]

service mariadb start
install_secure_policies
service mariadb stop
mariadbd
~~~
5. Now doesn't work because mariadb-secure-installation expects a tty and not a heredoc. So we need to do the operations manually: <br/>
https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script <br/>
and going to mariadb container and doing cat /usr/bin/mariadb-secure-installation, copying the queries <br/>
https://mariadb.com/kb/en/authentication-plugin-unix-socket/ <br/>
As the unix_socket is now enabled by default, there is no need to enable it again <br/>
Final result:
~~~
#! /bin/bash

intialize_service()
{
    service mariadb start
    sleep 1
}

install_secure_policies()
{
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

# Create a simple compose file with only mariadb
https://docs.docker.com/reference/compose-file/ <br/>
https://docs.docker.com/reference/compose-file/services/ <br/>
https://docs.docker.com/reference/compose-file/build/ <br/>
https://docs.docker.com/reference/compose-file/volumes/ <br/>
https://docs.docker.com/engine/extend/legacy_plugins/ <br/>
https://docs.docker.com/reference/compose-file/networks/ <br/>
https://docs.docker.com/reference/compose-file/secrets/

## Creating wordpress database volume
Having this simple docker-compose.yml:
~~~
name: inception

services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    restart: always

~~~
We need to create the database volume.
~~~
volumes:
  database:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}database
      o: bind
~~~
https://stackoverflow.com/questions/74079078/what-is-the-meaning-of-the-type-o-device-flags-in-driver-opts-in-the-docker-comp <br/>
https://stackoverflow.com/questions/71660515/docker-compose-how-to-remove-bind-mount-data <br/>
https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/

Final result:
~~~
name: inception

services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      - database:/var/lib/mysql
    restart: always

volumes:
  database:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}database
      o: bind
~~~


## Creating initial queries
As wordpress will connect to create the necessary tables, should we create the database or its created by default?: YES <br/>
https://wpdataaccess.com/docs/remote-databases/mysql-mariadb/ <br/>
https://www.sitepoint.com/community/t/how-does-wordpress-automatically-create-a-database-on-installation/112298 <br/>
https://ubuntu.com/tutorials/install-and-configure-wordpress#5-configure-database

Steps:
1. Create database: https://mariadb.com/kb/en/create-database/ <br/>
2. Create user to handle the database: <br/>
https://mariadb.com/kb/en/create-user/ <br/>
https://stackoverflow.com/questions/12931991/mysql-what-does-stand-for-in-host-column-and-how-to-change-users-password <br/>
3. Grant privileges on the database: https://mariadb.com/kb/en/grant/ <br/>
4. Refresh
~~~
[...]

initial_transaction()
{
    mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';"
    mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';"
    mariadb -e "FLUSH PRIVILEGES;"
}

intialize_service
install_secure_policies
initial_transaction
service mariadb stop
~~~

Final init_mariadb.sh result:
~~~
#! /bin/bash

intialize_service()
{
    service mariadb start
    sleep 1
}

install_secure_policies()
{
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

initial_transaction()
{
    mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';"
    mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';"
    mariadb -e "FLUSH PRIVILEGES;"
}

intialize_service
install_secure_policies
initial_transaction
service mariadb stop

mariadbd
~~~


# Wordpress and php-fpm
## Installing php-fpm
We need to install wordpress and php-fpm (PHP fastcgi process manager). <br/>
PHP package tries to install Apache2 (even some modules of PHP try to install it too), so we need to install php-fpm alone <br/>
https://askubuntu.com/questions/1160433/how-to-install-php-without-apache-webserver <br/>
Starting Dockerfile with only php-fpm
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm

EXPOSE 9000

ENTRYPOINT [ "tail", "-f", "/dev/null" ]
~~~
The <code>tail -f /dev/null</code> it's temporal, we will override it at the end


## Install and configure wordpress
### Install wp-cli
As wordpress must be installed and configured from start, without admin panel, we have to install wp-cli to install wordpress with it <br/>
https://make.wordpress.org/cli/handbook/guides/installing/
~~~
[...]

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

[...]
~~~
It fails: curl: (77) error setting certificate verify locations:  CAfile: /etc/ssl/certs/ca-certificates.crt CApath: /etc/ssl/certs <br/>
https://askubuntu.com/questions/1390288/curl-77-error-setting-certificate-verify-locations-ubuntu-20-04-3-lts <br/>
So we need to install ca-certificates
~~~
[...]

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates

[...]
~~~
We can enter the container with a shell and execute wp --info to see it's installed properly. <br/>
Final result:
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

EXPOSE 9000

ENTRYPOINT [ "tail", "-f", "/dev/null" ]
~~~
If we try to enter the container and execute wp core --help, it will deny because we are not root. So from now on, we will have to add
--allow-root to all the queries <br/>
https://www.reddit.com/r/Wordpress/comments/dwukz2/running_wpcli_commands_as_root/


### Install and configure wordpress using wp-cli
First, we need to add the wordpress service, volume and network to compose so we can fully test it works with mariadb container and .env
~~~
name: inception

services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      - database:/var/lib/mysql
    networks:
      - backend
    env_file: .env
    restart: always
  wordpress:
    container_name: wordpress
    build: requirements/wordpress
    volumes:
      - website:/var/www/html
    networks:
      - backend
    env_file: .env
    restart: always
    depends_on:
      - mariadb

networks:
  backend:
    driver: bridge

volumes:
  database:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}database
      o: bind
  website:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}website
      o: bind
~~~
Then, we download, configure and install wordpress with wp-cli: <br/>
https://make.wordpress.org/cli/handbook/how-to/how-to-install/ <br/>
We also need to create a non-admin user so: <br/>
https://developer.wordpress.org/cli/commands/user/create/

For it, we create init_wordpress.sh: <br/>
~~~
#! /bin/bash

install_and_configure_wordpress()
{
    if [ -f wp-config.php ]; then return 0; fi

    wp core download --allow-root
    wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --allow-root
    wp core install --url=$DOMAIN_NAME --title="$WEBSITE_TITLE" --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --allow-root
    wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD --allow-root
}

install_and_configure_wordpress
tail -f /dev/null
~~~
And as we want to execute the php-fpm as daemon, we need to execute it with the flag -F: <br/>
https://stackoverflow.com/questions/37313780/how-can-i-start-php-fpm-in-a-docker-container-by-default
~~~
[...]

php-fpm7.4 -F
~~~
Also, wordpress must be installed in the root directory of nginx, so we set the workdir there: <br/>
https://serverfault.com/questions/718449/default-directory-for-nginx
~~~
[...]

WORKDIR /var/www/html

[...]
~~~

We see 2 errors: <br/>
1. Undefined function mysqli_init(): <br/>
https://serverfault.com/questions/971430/wordpress-php-uncaught-error-call-to-undefined-function-mysql-connect <br/>
We need to install php-mysqli
~~~
[...]

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli

[...]
~~~
2. Unable to bind socket for address /run/php/php7.4-fpm.sock <br/>
Similar to how we fixed it in mariadb container, we need to create /run/php: <br/>
~~~
[...]

RUN mkdir -p /run/php && \
    chmod 777 /run/php

[...]
~~~
Final result of Dockerfile:
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && \
    chmod 777 /run/php

COPY --chmod=700 ./tools/init_wordpress.sh /root/init_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/root/init_wordpress.sh" ]
~~~
This also fails because it tries to send an email to the admin_email. We can prevent it with --skip-email <br/>
https://github.com/wp-cli/wp-cli/issues/1172 <br/>
Final result:
~~~
#! /bin/bash

install_and_configure_wordpress()
{
    if [ -f wp-config.php ]; then return 0; fi

    wp core download --allow-root
    wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --allow-root
    wp core install --url=$DOMAIN_NAME --title="$WEBSITE_TITLE" --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --skip-email --allow-root
    wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD --allow-root
}

install_and_configure_wordpress
php-fpm7.4 -F
~~~







# TIPS
1. When debugging, remember to delete the physical volumes (/home/xxx/data), as the persisted data can show you fake results
even if you rebuild
