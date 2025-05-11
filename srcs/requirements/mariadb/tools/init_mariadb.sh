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