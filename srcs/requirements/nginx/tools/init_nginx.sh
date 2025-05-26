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

# Bonus: Static website
copy_web_files()
{
    if [ -d ./web ]; then return 0; fi;

    cp -rf /root/web ./
}

create_tls_cert
copy_web_files
exec "$@"