# tcp-proxy-docker

## 简介

基于 [socat](http://www.dest-unreach.org/socat/) 实现的轻量级 TCP/UDP 端口转发工具,支持 IPv4/IPv6。

## 特性

- ✅ 支持 TCP、UDP 或同时转发
- ✅ 自动检测 IPv4/IPv6
- ✅ 灵活的配置格式
- ✅ 详细的日志输出
- ✅ 使用 host 网络模式,性能更优

## 快速开始

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 配置说明

首次使用需从示例文件复制配置:

```bash
cp tcp-proxy.conf.example tcp-proxy.conf
```

编辑 `tcp-proxy.conf` 文件:

### 格式 1: 默认转发 TCP+UDP

```
listen_port target_address
```

示例:
```
1005 192.168.0.7:1005
8080 10.0.0.1:80
```

### 格式 2: 指定协议

```
protocol listen_port target_address
```

协议选项: `TCP`, `UDP`, `BOTH`

示例:
```
# 仅转发 TCP
TCP 8080 192.168.0.7:80

# 仅转发 UDP
UDP 53 8.8.8.8:53

# 同时转发 TCP 和 UDP
BOTH 3306 192.168.1.100:3306
```

### IPv6 支持

使用方括号包裹 IPv6 地址:

```
BOTH 9000 [::1]:9000
TCP 8080 [2001:db8::1]:80
```

### 注释

以 `#` 开头的行会被忽略:

```
# 这是注释
1005 192.168.0.7:1005  # 行尾注释会导致解析错误,请避免
```

## 日志

日志文件位于容器内 `/var/log/tcp-proxy.log`,包含:
- 启动时间
- 每个代理的配置信息
- 错误信息

查看实时日志:
```bash
docker exec -it tcp_proxy tail -f /var/log/tcp-proxy.log
```

## 注意事项

1. 使用 `host` 网络模式,容器直接使用宿主机网络
2. 使用 `cap_add: NET_BIND_SERVICE` 绑定低端口
3. 确保监听端口未被占用
4. 修改配置后需重启容器: `docker-compose restart`
