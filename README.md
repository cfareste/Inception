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


## Configure php-fpm pools
https://www.digitalocean.com/community/tutorials/php-fpm-nginx <br/>
https://www.php.net/manual/en/install.fpm.configuration.php <br/>
and going to the wordpress container and reading the configuratin under /etc/php/x.x/fpm/pool.d/www.conf <br/>
What is the user www-data: https://askubuntu.com/questions/873839/what-is-the-www-data-user <br/>
Final result (remind that ; are comments here):
~~~
[inception]
; User and group that will execute the pool of processes
user = www-data
group = www-data

; What interfaces (IPs) and port should listen
listen = 0.0.0.0:9000

; How will fpm manage the pool processes: Dynamic means the number of
; processes will fluctuate, but there will be at least one children
pm = dynamic

; Maximum of processes alive (in other words, maximum of requests handled at the same time)
pm.max_children = 20

; Number of processes at start
pm.start_servers = 10

; Minimum 'idle' processes (waiting for process). If there are less 'idle' processes than
; this directive, some children processes will be created
pm.min_spare_servers = 1

; Maximum 'idle' processes (waiting for process). If there are more 'idle' processes than
; this directive, some children processes will be killed
pm.max_spare_servers = 15
~~~
How does php-fpm differentiate which pool configuration use on every request?: <br/>
Answer: By the listen directive. Every request coming in a concrete tcp / unix socket will
use the pool directive configured for that listen directive <br/>
https://www.tecmint.com/connect-nginx-to-php-fpm/

On the Dockerfile, we need to copy the configuration:
~~~
[...]

COPY ./conf/inception_pool.conf /etc/php/7.4/fpm/pool.d/inception.conf

[...]
~~~
Final result:
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli

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
~~~


# Nginx
Create a Dockerfile and install nginx only <br/>
To run nginx as a foreground process: https://www.uptimia.com/questions/how-to-run-nginx-in-the-foreground-within-a-docker-container
~~~
FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
~~~
## Add nginx service to docker-compose
Is the same as the other services but we need to add port forwarding (publishing ports). <br/>
For testing purposes, we will map the container port 80 with the host port 80 (when we add the
SSL certificate we will map both 443): <br/>
https://docs.docker.com/reference/compose-file/services/#ports <br/>
We do this because the browser expects a secure connection on the port 443, and if the server can't
handle it (as we didn't configure nginx, neither create a certificate), it returns a connection reset error: <br/>
You can check this on /etc/nginx/sites-available/default and https://serverfault.com/questions/842779/set-nginx-https-on-port-443-without-the-certificate <br/>
We also need to create a new network for the "frontend" part of the app (wordpress - nginx) <br/>
docker-compose.yml:
~~~
[...]
  nginx:
    container_name: nginx
    build: requirements/nginx
    volumes:
      - website:/var/www/html
    networks:
      - frontend
    ports:
      - "80:80"
    restart: always
    depends_on:
      - wordpress

networks:
  [...]
  frontend:
    driver: bridge

[...]
~~~
Nginx Dockerfile:
~~~
[...]

EXPOSE 80

[...]
~~~

## Configure Nginx to redirect the requests to our wordpress container
We need to create the configuration to listen on port 80 (we will change it to 443 later), with the
login.42.fr as domain, and to serve both static and dynamic files (using php-fpm on wordpress container) <br/>
https://nginx.org/en/docs/beginners_guide.html <br/>
https://nginx.org/en/docs/http/request_processing.html <br/>
https://nginx.org/en/docs/http/ngx_http_core_module.html
~~~
server {
    # Listen to specific port for IPv4 and IPv6
    listen 80;
    listen [::]:80;

    # Listen to requests that comes from this specific domain
    server_name cfidalgo.42.fr;

    # Set the root directory of every file (request of index.php will return /var/www/html/index.php).
    # The root must much with the wordpress files volume
    root /var/www/html;

    # Directive for every request that starts with / (every request, its a catch-all location)
    # setting the index file (the main file)
    location / {
        index index.html index.php;
    }

    # Directive for every request that finishes with .php
    location ~ \.php$ {
        # Pass the .php files to the FPM listening on this address
        fastcgi_pass  wordpress:9000;

        # FPM variables that set the full path to the file (/var/www/html/index.php) and the
        # file name itself (/index.php)
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param QUERY_STRING    $query_string;
    }
}
~~~
Where do we need to paste this config? Answer: /etc/nginx/sites-available and make a link to
it in sites-enabled (better practice). Or just in sites-enabled / conf.d directories if you are too lazy: <br/>
https://www.fegno.com/nginx-configuration-file-to-host-website-on-ubuntu/
~~~
[...]

COPY ./conf/inception_server.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/inception_server.conf /etc/nginx/sites-enabled/

EXPOSE 80

WORKDIR /var/www/html

[...]
~~~
This fails. All pages appears to be blank. This is caused because we need to pass more fastcgi_param variables to the php server. <br/>
https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html <br/>
https://developer.wordpress.org/advanced-administration/server/web-server/nginx/ <br/>
If we also go to the container of nginx and cat /etc/nginx/fastcgi.conf, we can see it contains all necessary variables for us
~~~
[...]

    # Directive for every request that finishes with .php
    location ~ \.php$ {
        # Pass the .php files to the FPM listening on this address
        fastcgi_pass  wordpress:9000;

        # Include the necessary variables
        include fastcgi.conf;
    }

[...]
~~~
This works, but we can improve this with some small details. <br/>
First, add the index directive to the server context directly (instead of the location) to get an index in every location. <br/>
https://nginx.org/en/docs/http/ngx_http_index_module.html <br/>
We can also add try_files directive to try the existence of the static files and process the request with them, or define another behavior <br/>
https://nginx.org/en/docs/http/ngx_http_core_module.html#try_files <br/>
https://en.wikipedia.org/wiki/Uniform_Resource_Identifier <br/>
Final result:
~~~
server {
    # Listen to specific port for IPv4 and IPv6
    listen 80;
    listen [::]:80;

    # Listen to requests that comes from this specific domain
    server_name cfidalgo.42.fr;

    # Set the root directory of every file (request of index.php will return /var/www/html/index.php)
    root /var/www/html;

    # Set the index file (the main file) globally, for every location
    index index.html index.php;

    # Directive for every request that starts with / (every request, its a catch-all location)
    location / {
        # Check if the static file exists. If not, check if the index file at that directory exists.
        # If neither exists, error 404 not found
        try_files $uri $uri/ =404;
    }

    # Directive for every request that finishes with .php
    location ~ \.php$ {
        # Check if php file exists; if not, error 404 not found
        try_files $uri =404;

        # Pass the .php files to the FPM listening on this address
        fastcgi_pass  wordpress:9000;

        # Include the necessary variables
        include fastcgi.conf;
    }
}
~~~


## TLS certificate
What is SSL and TLS: <br/>
https://www.cloudflare.com/learning/ssl/what-is-ssl/ <br/>
https://www.cloudflare.com/learning/ssl/what-happens-in-a-tls-handshake/ <br/>
https://www.cloudflare.com/learning/ssl/how-does-ssl-work/ <br/>
https://blog.cloudflare.com/rfc-8446-aka-tls-1-3/ <br/>
Why using RSA as the encrypting algorithm is dangerous:
https://crypto.stackexchange.com/questions/47512/why-plain-rsa-encryption-does-not-achieve-cpa-security <br/>

We need to create a self-signed certificate, with both it's public and private key: <br/>
https://dev.to/techschoolguru/how-to-create-sign-ssl-tls-certificates-2aai <br/>
https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu <br/>
We will create it in the create_tls_cert.sh script:
~~~
#! /bin/bash

create_tls_cert()
{
    if [ -f /etc/ssl/certs/inception.crt ] && [ -f /etc/ssl/private/inception.key ]; then return 0; fi;

    openssl req -x509 \
                -nodes \
                -days 365 \
                -newkey rsa:4096 \
                -keyout /etc/ssl/private/inception.key \
                -out /etc/ssl/certs/inception.crt \
                -subj "/C=SP/ST=Barcelona/L=Barcelona/O=42bcn/OU=42bcn/CN=cfidalgo.42.fr/emailAddress=cfidalgo@gmail.com"
}

create_tls_cert
nginx -g 'daemon off;'
~~~
Then, in Dockerfile:
~~~
[...]

COPY --chmod=700 ./tools/create_tls_cert.sh /root/

[...]

ENTRYPOINT [ "/root/create_tls_cert.sh" ]
~~~

Then, we need to adapt our nginx server to accept SSL connections: <br/>
http://nginx.org/en/docs/http/configuring_https_servers.html <br/>
On our nginx configuration:
~~~
server {
    # Listen to specific port for IPv4 and IPv with TLS connections
    listen 443 ssl;
    listen [::]:443 ssl;

    # Listen to requests that comes from this specific domain
    server_name cfidalgo.42.fr;

    # Locations of the SSL cert and key
    ssl_certificate     /etc/ssl/certs/inception.crt;
    ssl_certificate_key /etc/ssl/private/inception.key;

    # Which TLS protocol is active
    ssl_protocols       TLSv1.3;

   [...]

}
~~~
We also need to expose the port 443 and publish it too on the docker-compose.yml: <br/>
Dockerfile
~~~
[...]

EXPOSE 443

[...]
~~~
docker-compose.yml
~~~
[...]
    ports:
      - "443:443"
[...]
~~~


# Add Docker secrets
In a production environment, you would use secrets for sensitive data: <br/>
https://docs.docker.com/reference/compose-file/services/#secrets <br/>
https://docs.docker.com/reference/compose-file/secrets/ <br/>
We need to create a secret for every sensitive variable, and replace that .env variable for the path to their
relative secret <br/>
.env before:
~~~
VOLUMES_PATH=PATH_TO_VOLUMES_DIRECTORY
DOMAIN_NAME=YOUR_DOMAIN_NAME

DATABASE_NAME=THE_MARIADB_DATABASE_NAME
DATABASE_USER_NAME=THE_MARIADB_DATABASE_USER_NAME
DATABASE_USER_PASSWORD=THE_MARIADB_DATABASE_USER_PASSWORD

DATABASE_HOST=THE_SERVICE_NAME_OF_THE_DATABASE
WEBSITE_TITLE=THE_WEBSITE_TITLE
WEBSITE_AUTHOR_USER=THE_WORDPRESS_AUTHOR_USER
WEBSITE_AUTHOR_PASSWORD=THE_WORDPRESS_AUTHOR_PASSWORD
WEBSITE_AUTHOR_EMAIL=THE_WORDPRESS_AUTHOR_EMAIL
WEBSITE_ADMIN_USER=THE_WORDPRESS_ADMIN_USER
WEBSITE_ADMIN_PASSWORD=THE_WORDPRESS_ADMIN_PASSWORD
WEBSITE_ADMIN_EMAIL=THE_WORDPRESS_ADMIN_EMAIL
~~~
and .env after
~~~
VOLUMES_PATH=PATH_TO_VOLUMES_DIRECTORY
DOMAIN_NAME=YOUR_DOMAIN_NAME

DATABASE_NAME_SECRET_PATH=PATH_TO_THE_SECRET                # Extracted to a secret; Now the variable contains the secret path
DATABASE_USER_NAME_SECRET_PATH=PATH_TO_THE_SECRET           # Extracted to a secret; Now the variable contains the secret path
DATABASE_USER_PASSWORD_SECRET_PATH=PATH_TO_THE_SECRET       # Extracted to a secret; Now the variable contains the secret path

DATABASE_HOST=THE_SERVICE_NAME_OF_THE_DATABASE
WEBSITE_TITLE=THE_WEBSITE_TITLE
WEBSITE_AUTHOR_USER=THE_WORDPRESS_AUTHOR_USER
WEBSITE_AUTHOR_PASSWORD_SECRET_PATH=PATH_TO_THE_SECRET      # Extracted to a secret; Now the variable contains the secret path
WEBSITE_AUTHOR_EMAIL=THE_WORDPRESS_AUTHOR_EMAIL
WEBSITE_ADMIN_USER_SECRET_PATH=PATH_TO_THE_SECRET           # Extracted to a secret; Now the variable contains the secret path
WEBSITE_ADMIN_PASSWORD_SECRET_PATH=PATH_TO_THE_SECRET       # Extracted to a secret; Now the variable contains the secret path
WEBSITE_ADMIN_EMAIL_SECRET_PATH=PATH_TO_THE_SECRET          # Extracted to a secret; Now the variable contains the secret path

SECRETS_PREFIX=/run/secrets                                 # New variable; Secrets directory inside a container
~~~

Then, on the docker-compose.yml, we create the secrets directive:
~~~
[...]

secrets:
  database_name:
    file: ${DATABASE_NAME_SECRET_PATH}
  database_user_name:
    file: ${DATABASE_USER_NAME_SECRET_PATH}
  database_user_password:
    file: ${DATABASE_USER_PASSWORD_SECRET_PATH}
  website_admin_email:
    file: ${WEBSITE_ADMIN_EMAIL_SECRET_PATH}
  website_admin_password:
    file: ${WEBSITE_ADMIN_PASSWORD_SECRET_PATH}
  website_admin_user:
    file: ${WEBSITE_ADMIN_USER_SECRET_PATH}
  website_author_password:
    file: ${WEBSITE_AUTHOR_PASSWORD_SECRET_PATH}
~~~
And also add the necessary secrets to each service:
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
    secrets:
      - database_name
      - database_user_name
      - database_user_password
    env_file: .env
    restart: always
  wordpress:
    container_name: wordpress
    build: requirements/wordpress
    volumes:
      - website:/var/www/html
    networks:
      - backend
      - frontend
    secrets:
      - database_name
      - database_user_name
      - database_user_password
      - website_admin_email
      - website_admin_password
      - website_admin_user
      - website_author_password
    env_file: .env
    restart: always
    depends_on:
      - mariadb
    [...]
~~~

Lastly, replace the variables in the scripts for the secrets: <br/>
In init_mariadb.sh:
~~~
[...]

initial_transaction()
{
    local DATABASE_NAME=$(cat $SECRETS_PREFIX/database_name)
    local DATABASE_USER_NAME=$(cat $SECRETS_PREFIX/database_user_name)
    local DATABASE_USER_PASSWORD=$(cat $SECRETS_PREFIX/database_user_password)

    mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';"
    mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';"
    mariadb -e "FLUSH PRIVILEGES;"
}

[...]
~~~
And in init_wordpress.sh:
~~~
[...]

install_and_configure_wordpress()
{
    if [ -f wp-config.php ]; then return 0; fi

    local DATABASE_NAME=$(cat $SECRETS_PREFIX/database_name)
    local DATABASE_USER_NAME=$(cat $SECRETS_PREFIX/database_user_name)
    local DATABASE_USER_PASSWORD=$(cat $SECRETS_PREFIX/database_user_password)
    local WEBSITE_ADMIN_USER=$(cat $SECRETS_PREFIX/website_admin_user)
    local WEBSITE_ADMIN_PASSWORD=$(cat $SECRETS_PREFIX/website_admin_password)
    local WEBSITE_ADMIN_EMAIL=$(cat $SECRETS_PREFIX/website_admin_email)
    local WEBSITE_AUTHOR_PASSWORD=$(cat $SECRETS_PREFIX/website_author_password)

    wp core download --allow-root
    wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --dbhost=$DATABASE_HOST --allow-root
    wp core install --url=$DOMAIN_NAME --title="$WEBSITE_TITLE" --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --admin_email=$WEBSITE_ADMIN_EMAIL --skip-email --allow-root
    wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD --allow-root
}

[...]
~~~


# TIPS
1. When debugging, remember to delete the physical volumes (/home/xxx/data), as the persisted data can show you fake results
even if you rebuild
