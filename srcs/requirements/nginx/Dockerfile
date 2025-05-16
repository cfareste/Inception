FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx openssl

COPY ./nginx/conf/inception_server.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/inception_server.conf /etc/nginx/sites-enabled/

COPY --chmod=700 ./nginx/tools/create_tls_cert.sh /root/

EXPOSE 443

WORKDIR /var/www/html

# Bonus
COPY ./bonus/web/ ./web

ENTRYPOINT [ "/root/create_tls_cert.sh" ]
