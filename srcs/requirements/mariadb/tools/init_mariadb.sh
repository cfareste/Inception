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
    local DATABASE_NAME=$(cat $SECRETS_PREFIX/database_name)
    local DATABASE_USER_NAME=$(cat $SECRETS_PREFIX/database_user_name)
    local DATABASE_USER_PASSWORD=$(cat $SECRETS_PREFIX/database_user_password)

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