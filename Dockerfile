FROM alpine:3.19

# 使用国内镜像源加速
RUN sed -i 's!http://dl-cdn.alpinelinux.org/!https://mirrors.ustc.edu.cn/!g' /etc/apk/repositories && \
    apk add --no-cache bash socat tzdata

COPY --chmod=755 entrypoint.sh /usr/bin/entrypoint

ENTRYPOINT ["/usr/bin/entrypoint"]
