#! /bin/bash

create_ftpuser()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)
    local FTP_PASSWORD=$(cat $SECRETS_PREFIX/ftp_password)

    if [ ! -z "$(cat /etc/passwd | grep $FTP_USER)" ]; then return 0; fi

    useradd -s /bin/bash -m $FTP_USER
    echo "$FTP_USER":"$FTP_PASSWORD" | chpasswd
}

create_files_directory()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)

    mkdir -p ./files && chown -R "$FTP_USER":"$FTP_USER" ./files
}

create_ftpuser
create_files_directory
vsftpd /etc/vsftpd/ftp_inception.conf