FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx openssl

COPY ./conf/inception_server.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/inception_server.conf /etc/nginx/sites-enabled/

COPY --chmod=700 ./tools/create_tls_cert.sh /root/

EXPOSE 443

WORKDIR /var/www/html

ENTRYPOINT [ "/root/create_tls_cert.sh" ]
