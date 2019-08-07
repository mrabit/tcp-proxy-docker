# tcp-proxy-docker

## 简介

通过 [socat](http://www.dest-unreach.org/socat/) 实现 TCP端口转发

## 使用

```shell
# 构建docker镜像
docker build -t tcp-proxy .
# 创建配置文件
mv tcp-proxy.conf /etc
# 运行容器
docker run --name proxy -d -v /etc/tcp-proxy.conf:/etc/tcp-proxy.conf --net=host tcp-proxy
```

## tcp-proxy.conf配置

```
#localPort targetHost:targetPort
1098 127.0.0.1:80
1099 127.0.0.1:80
```

