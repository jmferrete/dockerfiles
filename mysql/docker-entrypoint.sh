#!/bin/bash

/usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf >/var/log/mysqld_out.log

exec "$@"
