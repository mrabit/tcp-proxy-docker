FROM alpine:3.19

# 使用国内镜像源加速
RUN sed -i 's!http://dl-cdn.alpinelinux.org/!https://mirrors.ustc.edu.cn/!g' /etc/apk/repositories && \
    apk add --no-cache bash socat tzdata && \
    rm -rf /var/cache/apk/*

# 复制代理脚本
COPY tcp-proxy.sh /usr/bin/tcp-proxy
RUN chmod +x /usr/bin/tcp-proxy

# 创建日志目录
RUN mkdir -p /var/log

ENTRYPOINT ["/usr/bin/tcp-proxy"]
