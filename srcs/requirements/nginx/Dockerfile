FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx

EXPOSE 80

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
