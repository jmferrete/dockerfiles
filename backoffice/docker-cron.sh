#!/bin/bash

service rsyslog start
cron -f >/var/log/cron_out.log 2>&1

