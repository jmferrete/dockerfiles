FROM ubuntu:trusty

RUN echo "export TERM=xterm" >> /root/.bashrc

RUN apt-get update && apt-get install -y nginx

COPY nginx.conf /etc/nginx/nginx.conf

# Uncomment only if exists mysite.com value for server_name config property
#COPY 001-php /etc/nginx/sites-available/001-php
#ENV APP_SITE_NAME="mysite.com"
#RUN sed -i "s/mysite.com/${APP_SITE_NAME}/" /etc/nginx/sites-available/001-php

RUN rm -f /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/001-php /etc/nginx/sites-enabled/

CMD ["/usr/sbin/nginx"]

EXPOSE 80
