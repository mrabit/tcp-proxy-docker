#!/usr/bin/env bash

CONFIG_FILE="/etc/tcp-proxy.conf"
LOG_FILE="/var/log/tcp-proxy.log"

# Ensure log file exists
touch "$LOG_FILE"

# Function to start socat for TCP and UDP
start_socat() {
    local listen_port=$1
    local target_address=$2

    # Determine if target_address is IPv4 or IPv6
    if [[ $target_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+: ]]; then
        # IPv4
        socat -d TCP4-LISTEN:${listen_port},fork,reuseaddr TCP4:${target_address} &
        echo "relay TCP/IPv4 connections on :${listen_port} to ${target_address}" >> "$LOG_FILE"
        
        socat -d UDP4-RECVFROM:${listen_port},fork,reuseaddr UDP4-SENDTO:${target_address} &
        echo "relay UDP/IPv4 connections on :${listen_port} to ${target_address}" >> "$LOG_FILE"
    elif [[ $target_address =~ ^\[.*\]: ]]; then
        # IPv6
        socat -d TCP6-LISTEN:${listen_port},fork,reuseaddr TCP6:${target_address} &
        echo "relay TCP/IPv6 connections on :${listen_port} to ${target_address}" >> "$LOG_FILE"
        
        socat -d UDP6-RECVFROM:${listen_port},fork,reuseaddr UDP6-SENDTO:${target_address} &
        echo "relay UDP/IPv6 connections on :${listen_port} to ${target_address}" >> "$LOG_FILE"
    else
        echo "Invalid target address: $target_address" >> "$LOG_FILE"
        return 1
    fi
}

# Read configuration file line by line
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Split line into listen port and target address
    IFS=' ' read -r -a LISTEN <<< "$line"
    
    # Validate input format
    if [[ ${#LISTEN[@]} -ne 2 ]]; then
        echo "Invalid configuration line: $line" >> "$LOG_FILE"
        continue
    fi
    
    start_socat "${LISTEN[0]}" "${LISTEN[1]}"
done < "$CONFIG_FILE"
echo -e "\n"
# Keep log output in the foreground
tail -f "$LOG_FILE"
