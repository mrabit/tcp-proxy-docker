# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

基于 socat 的轻量级 TCP/UDP 端口转发 Docker 工具，支持 IPv4/IPv6。

## 常用命令

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 查看容器内实时日志
docker exec -it tcp_proxy tail -f /var/log/tcp-proxy.log

# 重启（配置修改后需要）
docker-compose restart

# 停止
docker-compose down
```

## 架构

四个核心文件：

- **tcp-proxy.sh** — 主脚本，解析配置文件并为每条规则启动 socat 进程
- **tcp-proxy.conf** — 转发规则配置，挂载到容器 `/etc/tcp-proxy.conf`
- **Dockerfile** — 基于 Alpine 3.19，安装 bash/socat/tzdata（使用 USTC 国内镜像源）
- **docker-compose.yml** — host 网络模式 + `cap_add: NET_BIND_SERVICE`

## 配置格式

```
# 2字段：默认 TCP+UDP 转发
listen_port target_address

# 3字段：指定协议（TCP/UDP/BOTH）
protocol listen_port target_address
```

IPv6 地址用方括号包裹：`[::1]:9000`

## 关键实现细节

- `detect_ip_version` 通过检测地址是否含 `[` 来区分 IPv4/IPv6
- 配置文件不支持行尾注释（会导致解析错误）
- socat 后台运行，主进程通过 `tail -f` 保持容器存活
- 使用 host 网络模式，容器直接使用宿主机网络栈
