#!/bin/bash

/etc/init.d/php5-fpm restart 2>&1 & disown
/etc/init.d/memcached restart 2>&1 & disown
nginx

