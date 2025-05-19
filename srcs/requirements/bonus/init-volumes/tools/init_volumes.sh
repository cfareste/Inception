#!/bin/bash

create_adminer_directory()
{
    mkdir -p ./adminer
    chown -R www-data:www-data ./adminer
    chmod -R 2755 ./adminer
}

create_ftp_directory()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)

    if [ -z "$(cat /etc/passwd | grep $FTP_USER)" ]
    then
        useradd -s /bin/bash -m $FTP_USER
    fi

    mkdir -p ./files
    chown -R "$FTP_USER":"www-data" ./files
    chmod -R 2755 ./files
}

change_root_owner()
{
    chown -R www-data:www-data ./
    chmod -R 755 ./
}

change_root_owner
create_adminer_directory
create_ftp_directory
