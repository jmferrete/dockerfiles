FROM ubuntu:trusty

RUN echo "export TERM=xterm" >> /root/.bashrc


# Check for php5-xcache vs php-apc
RUN apt-get update && apt-get install -y php5 php5-fpm php-apc php5-apcu php5-mysql nginx memcached

COPY 001-mysite.com /etc/nginx/sites-available/001-mysite.com
COPY cache.conf /etc/nginx/conf.d/cache.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY htpasswd /etc/nginx/.htpasswd
COPY php.ini /etc/php5/fpm/php.ini
COPY php-fpm.conf /etc/php5/fpm/php-fpm.conf
COPY www.conf /etc/php5/fpm/pool.d/www.conf
COPY ssl.conf /etc/nginx/conf.d/ssl.conf
COPY apcu.ini /etc/php5/mods-available/apcu.ini
#COPY xcache.ini /etc/php5/mods-available/xcache.ini
COPY memcached.conf /etc/memcached.conf

# Uncomment only if exists mysite.com value for server_name config property
#COPY 001-php /etc/nginx/sites-available/001-php
#ENV APP_SITE_NAME="www.mysite.com"
#RUN sed -i "s/mysite.com/${APP_SITE_NAME}/" /etc/nginx/sites-available/001-php

RUN rm -f /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/001-mysite.com /etc/nginx/sites-enabled/ \

VOLUME /var/www

RUN chown -R www-data:www-data /var/www

COPY docker-httpd.sh /httpd.sh
RUN chmod 750 /httpd.sh
CMD ["/httpd.sh"]

EXPOSE 80
