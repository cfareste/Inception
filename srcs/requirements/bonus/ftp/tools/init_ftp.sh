#! /bin/bash

create_ftpuser()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)
    local FTP_PASSWORD=$(cat $SECRETS_PREFIX/ftp_password)

    if [ ! -z "$(cat /etc/passwd | grep $FTP_USER)" ]; then return 0; fi

    useradd -s /bin/bash -m $FTP_USER
    echo "$FTP_USER":"$FTP_PASSWORD" | chpasswd
}

create_ftpuser
exec "$@"