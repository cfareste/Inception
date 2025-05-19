FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends vsftpd

COPY ./conf/ftp.conf /etc/vsftpd/ftp_inception.conf

COPY --chmod=700 tools/init_ftp.sh /root/init_ftp.sh

RUN mkdir -p /run/vsftpd/empty

WORKDIR /var/www/html

EXPOSE 21
EXPOSE 49152-49162

ENTRYPOINT [ "/root/init_ftp.sh" ]