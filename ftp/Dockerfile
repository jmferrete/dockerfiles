FROM ubuntu:trusty

RUN echo "export TERM=xterm" >> /root/.bashrc

RUN apt-get update && apt-get install -y vsftpd

COPY vsftpd.conf /etc/vsftpd.conf

VOLUME /home

EXPOSE 21
EXPOSE 10000-10010

COPY docker-vsftpd.sh /vsftpd.sh
RUN chmod 750 /vsftpd.sh
CMD ["/vsftpd.sh"]
