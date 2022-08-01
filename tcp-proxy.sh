#!/usr/bin/env bash

IFS=$'\n'
for line in $(cat /etc/tcp-proxy.conf)
do 
    IFS=' '
    LISTEN=(${line})
    exec socat -d TCP-LISTEN:${LISTEN[0]},fork,reuseaddr TCP:${LISTEN[1]} &
    echo "relay TCP/IP connections on :${LISTEN[0]} to ${LISTEN[1]}" >> /var/log/tcp-proxy.log
    exec socat -d UDP4-RECVFROM:${LISTEN[0]},fork,reuseaddr UDP4-SENDTO:${LISTEN[1]} &
    echo "relay UDP/IP connections on :${LISTEN[0]} to ${LISTEN[1]}" >> /var/log/tcp-proxy.log
done

tail -f /var/log/tcp-proxy.log

