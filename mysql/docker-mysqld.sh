#!/bin/bash

/usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf >/var/log/mysqld_out.log 2>&1 & disown

while true; do sleep 60; done
