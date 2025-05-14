FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx

COPY ./conf/inception_server.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/inception_server.conf /etc/nginx/sites-enabled/

EXPOSE 80

WORKDIR /var/www/html

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
