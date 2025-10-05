#!/bin/bash

# 输出文件
OUTPUT="hosts"

# 确保 jq 已安装
if ! command -v jq >/dev/null 2>&1; then
    echo "❌ 缺少 jq，请先安装: sudo apt-get install jq"
    exit 1
fi

# 临时变量存结果
results=""

# 按行读取 domain.txt
while IFS= read -r domain; do
    # 跳过空行或注释行
    [ -z "$domain" ] && continue
    [[ "$domain" =~ ^# ]] && continue

    # 请求 API
    json=$(curl -s "https://github-hosts.tinsfox.com/$domain")

    # 提取 IP
    ip=$(echo "$json" | jq -r '.ip')

    # 如果 IP 存在则写入结果
    if [ -n "$ip" ] && [ "$ip" != "null" ]; then
        results+="$ip $domain"$'\n'
    else
        results+="# Failed to fetch $domain"$'\n'
    fi
done < domain.txt

# 写入 hosts 文件，并加时间戳
{
    echo "# Generated at $(date '+%Y-%m-%d %H:%M:%S')"
    echo "$results"
} > "$OUTPUT"

echo "✅ 已完成，结果输出到 $OUTPUT"

