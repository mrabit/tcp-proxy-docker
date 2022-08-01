FROM alpine:3.10.1

RUN sed -i 's!http://dl-cdn.alpinelinux.org/!https://mirrors.ustc.edu.cn/!g' /etc/apk/repositories
RUN apk add --update bash socat

COPY tcp-proxy.sh /usr/bin/tcp-proxy

ENTRYPOINT ["/bin/sh", "-c", "tcp-proxy"]
