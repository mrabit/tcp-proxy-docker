# tcp-proxy-docker

## 简介

通过 [socat](http://www.dest-unreach.org/socat/) 实现 TCP/UDP 端口转发

## 使用

```shell
# 构建docker镜像
docker-compose up -d
```

## tcp-proxy.conf 配置

```
#localPort targetHost:targetPort
1098 127.0.0.1:80
1099 127.0.0.1:80
```
