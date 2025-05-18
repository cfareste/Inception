#! /bin/bash

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

# Bonus: Install and configure redis-cache plugin
install_and_configure_redis_plugin()
{
    # Check if redis-cache plugin is installed
    wp plugin is-installed redis-cache --allow-root
    
    # If the last command returns 0, means is installed, so return
    if [ $? -eq 0 ]; then return 0; fi;

    # Install plugin
    wp plugin install redis-cache --activate --allow-root
    
    # Set redis configurations in wp-config.php
    wp config set WP_REDIS_HOST "redis" --allow-root
    wp config set WP_REDIS_PORT "6379" --allow-root
    wp config set WP_REDIS_PREFIX "inception" --allow-root
    wp config set WP_REDIS_DATABASE "0" --allow-root
    wp config set WP_REDIS_TIMEOUT "1" --allow-root
    wp config set WP_REDIS_READ_TIMEOUT "1" --allow-root

    # Enable object cache
    wp redis enable --allow-root
}

install_and_configure_wordpress
install_and_configure_redis_plugin
chown -R www-data:www-data ./ && chmod -R 750 ./
php-fpm7.4 -F
