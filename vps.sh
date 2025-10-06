#!/bin/bash

DNS_SERVER="9.9.9.9"
DOMAIN_FILE="domain.txt"
OUTPUT_FILE="hosts"
TCPING="./tcping"
MAX_PARALLEL=5   # 并行 tcping 数量，可根据机器调整

> "$OUTPUT_FILE"

mapfile -t domains < "$DOMAIN_FILE"

for domain in "${domains[@]}"; do
    domain=$(echo "$domain" | xargs)
    [ -z "$domain" ] && continue
    echo "Processing $domain..."

    # 获取3次 IP，并去重
    ips=($(for i in {1..3}; do
        dig @$DNS_SERVER +short "$domain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1
    done | sort -u))

    [ ${#ips[@]} -eq 0 ] && { echo "No IP found for $domain"; continue; }

    declare -A ip_latency_map

    # 并行 tcping 测延迟
    tmp_file=$(mktemp)
    for ip in "${ips[@]}"; do
        (
            result=$($TCPING "$domain" 443 -j -c 2)
            avg_latency=$(echo "$result" | grep '"latency_avg"' | head -n1 | sed -E 's/.*"latency_avg":"([0-9.]+)".*/\1/')
            echo "$ip $avg_latency" >> "$tmp_file"
        ) &
        
        # 控制并行数
        while [ $(jobs -r | wc -l) -ge $MAX_PARALLEL ]; do
            sleep 0.1
        done
    done

    wait

    # 读取延迟结果，找到最小值
    while read -r ip latency; do
        [ -z "$latency" ] && continue
        ip_latency_map["$ip"]=$latency
    done < "$tmp_file"

    rm -f "$tmp_file"

    # 找到延迟最低的 IP
    min_ip=""
    min_latency=999999
    for ip in "${!ip_latency_map[@]}"; do
        latency=${ip_latency_map[$ip]}
        awk_latency=$(awk "BEGIN {print ($latency < $min_latency)}")
        if [ "$awk_latency" -eq 1 ]; then
            min_latency=$latency
            min_ip=$ip
        fi
    done

    if [ -n "$min_ip" ]; then
        echo "$min_ip $domain" >> "$OUTPUT_FILE"
        echo "Selected $min_ip for $domain (latency: $min_latency ms)"
    else
        echo "No valid IP found for $domain"
    fi

    unset ip_latency_map
done

echo "Hosts file generated: $OUTPUT_FILE"
