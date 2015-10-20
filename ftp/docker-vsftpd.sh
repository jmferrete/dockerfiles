#!/bin/bash

. /etc/init/vsftpd.conf >/dev/null 2>&1 & disown

while true; do sleep 60; done
