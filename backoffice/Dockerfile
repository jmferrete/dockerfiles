FROM ubuntu:trusty

RUN echo "export TERM=xterm" >> /root/.bashrc

# Check for php5-xcache vs php-apc
RUN apt-get update && apt-get install -y php5 php5-fpm php-apc php5-apcu php5-mysql php5-cli nano

COPY php.ini /etc/php5/fpm/php.ini
COPY php-fpm.conf /etc/php5/fpm/php-fpm.conf
COPY www.conf /etc/php5/fpm/pool.d/www.conf
COPY apcu.ini /etc/php5/mods-available/apcu.ini
#COPY xcache.ini /etc/php5/mods-available/xcache.ini
RUN touch /var/log/cron.log

VOLUME /opt/backoffice
VOLUME /var/backups
VOLUME /var/spool/cron/crontabs

COPY docker-cron.sh /cron.sh
RUN chmod 750 /cron.sh
CMD ["/cron.sh"]

