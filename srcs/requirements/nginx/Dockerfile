FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
