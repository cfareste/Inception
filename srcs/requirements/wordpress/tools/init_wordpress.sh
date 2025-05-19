#! /bin/bash

# Bonus: init-volumes service
execute_as_www_data()
{
    # Execute as www-data every wp command using bash
    su -s /bin/bash www-data -c "$1"
}

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

    execute_as_www_data "wp core download"
    execute_as_www_data "wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --dbhost=$DATABASE_HOST"
    execute_as_www_data "wp core install --url=$DOMAIN_NAME --title=$WEBSITE_TITLE --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --admin_email=$WEBSITE_ADMIN_EMAIL --skip-email"
    execute_as_www_data "wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD"
}

# Bonus: Install and configure redis-cache plugin
install_and_configure_redis_plugin()
{
    # Check if redis-cache plugin is installed
    execute_as_www_data "wp plugin is-installed redis-cache"
    
    # If the last command returns 0, means is installed, so return
    if [ $? -eq 0 ]; then return 0; fi;

    # Install plugin
    execute_as_www_data "wp plugin install redis-cache --activate"
    
    # Set redis configurations in wp-config.php
    execute_as_www_data "wp config set WP_REDIS_HOST \"redis\""
    execute_as_www_data "wp config set WP_REDIS_PORT \"6379\""
    execute_as_www_data "wp config set WP_REDIS_PREFIX \"inception\""
    execute_as_www_data "wp config set WP_REDIS_DATABASE \"0\""
    execute_as_www_data "wp config set WP_REDIS_TIMEOUT \"1\""
    execute_as_www_data "wp config set WP_REDIS_READ_TIMEOUT \"1\""

    # Enable object cache
    execute_as_www_data "wp redis enable"
}

install_and_configure_wordpress
install_and_configure_redis_plugin
php-fpm7.4 -F
