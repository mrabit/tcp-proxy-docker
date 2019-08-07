# tcp-proxy-docker

## 简介

通过 [socat](http://www.dest-unreach.org/socat/) 实现 TCP端口转发

## 使用

```shell
touch /etc/tcp-proxy.conf
docker run --name proxy -d -v /etc/tcp-proxy.conf:/etc/tcp-proxy.conf --net=host tcp-proxy
```

## tcp-proxy.conf配置

```
#localPort targetHost:targetPort
1098 127.0.0.1:80
1099 127.0.0.1:80
```

