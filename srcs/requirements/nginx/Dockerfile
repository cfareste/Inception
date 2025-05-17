FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx openssl

COPY ./nginx/conf/inception_server.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/inception_server.conf /etc/nginx/sites-enabled/

COPY --chmod=700 ./nginx/tools/init_nginx.sh /root/

EXPOSE 443

WORKDIR /var/www/html

# Bonus: Static website
COPY ./bonus/web/ /root/web

ENTRYPOINT [ "/root/init_nginx.sh" ]
