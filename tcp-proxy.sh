#!/usr/bin/env bash

IFS=$'\n'
for line in $(cat /etc/tcp-proxy.conf)
do 
    IFS=' '
    LISTEN=(${line})
    echo "relay TCP/IP connections on :${LISTEN[0]} to ${LISTEN[1]}" >> /var/log/tcp-proxy.log
    exec socat -d TCP-LISTEN:${LISTEN[0]},fork,reuseaddr TCP:${LISTEN[1]} &
done

tail -f /var/log/tcp-proxy.log

