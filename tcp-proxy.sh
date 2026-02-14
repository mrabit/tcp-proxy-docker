#!/usr/bin/env bash

CONFIG_FILE="/etc/tcp-proxy.conf"
LOG_FILE="/var/log/tcp-proxy.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# 检测 IP 版本
detect_ip_version() {
    local address=$1
    if [[ $address =~ ^\[.*\]: ]]; then
        echo "6"
    else
        echo "4"
    fi
}

# 启动单个 socat 代理
start_proxy() {
    local protocol=$1
    local listen_port=$2
    local target_address=$3
    local ip_version=$(detect_ip_version "$target_address")
    
    case "${protocol^^}" in
        TCP)
            socat -d TCP${ip_version}-LISTEN:${listen_port},fork,reuseaddr TCP${ip_version}:${target_address} &
            log "✓ TCP/IPv${ip_version} :${listen_port} → ${target_address}"
            ;;
        UDP)
            socat -d UDP${ip_version}-RECVFROM:${listen_port},fork,reuseaddr UDP${ip_version}-SENDTO:${target_address} &
            log "✓ UDP/IPv${ip_version} :${listen_port} → ${target_address}"
            ;;
        BOTH|*)
            socat -d TCP${ip_version}-LISTEN:${listen_port},fork,reuseaddr TCP${ip_version}:${target_address} &
            socat -d UDP${ip_version}-RECVFROM:${listen_port},fork,reuseaddr UDP${ip_version}-SENDTO:${target_address} &
            log "✓ TCP+UDP/IPv${ip_version} :${listen_port} → ${target_address}"
            ;;
    esac
}

# 解析配置文件
parse_config() {
    local line_num=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # 跳过空行和注释
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # 移除行首尾空格
        line=$(echo "$line" | xargs)
        
        # 解析配置: [protocol] listen_port target_address
        local parts=($line)
        local protocol="BOTH"
        local listen_port
        local target_address
        
        case ${#parts[@]} in
            2)
                # 格式: listen_port target_address (默认 TCP+UDP)
                listen_port=${parts[0]}
                target_address=${parts[1]}
                ;;
            3)
                # 格式: protocol listen_port target_address
                protocol=${parts[0]}
                listen_port=${parts[1]}
                target_address=${parts[2]}
                ;;
            *)
                log "✗ 第 ${line_num} 行配置格式错误: $line"
                continue
                ;;
        esac
        
        # 验证端口号
        if ! [[ "$listen_port" =~ ^[0-9]+$ ]] || [ "$listen_port" -lt 1 ] || [ "$listen_port" -gt 65535 ]; then
            log "✗ 第 ${line_num} 行端口号无效: $listen_port"
            continue
        fi
        
        # 验证目标地址格式
        if ! [[ "$target_address" =~ ^(\[.*\]|[^:]+):[0-9]+$ ]]; then
            log "✗ 第 ${line_num} 行目标地址格式错误: $target_address"
            continue
        fi
        
        start_proxy "$protocol" "$listen_port" "$target_address"
    done < "$CONFIG_FILE"
}

# 主程序
main() {
    log "=========================================="
    log "TCP/UDP Proxy 启动中..."
    log "配置文件: $CONFIG_FILE"
    log "=========================================="
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "✗ 配置文件不存在: $CONFIG_FILE"
        exit 1
    fi
    
    parse_config
    
    log "=========================================="
    log "所有代理已启动,开始监控日志..."
    log "=========================================="
    
    # 保持容器运行并输出日志
    tail -f "$LOG_FILE"
}

main
