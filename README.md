# 100% AI生成
# TradingView Hosts

就像Github和Onedrive一样，SNI未被屏蔽。只是被DNS污染，导致污染访问。

# IP质量

Tradingview有使用亚马逊 (AWS) 的 CloudFront CDN，但对CDN使用并不积极使用。

也没有积极适配大陆市场，大部分IP质量差

# 自己生成

## update.sh

脚本使用api 【https://github-hosts.tinsfox.com/】 获取域名IP，不进行大陆有效性测试

## vps.sh

在 香港vps上运行，获取最近的ip地址。不进行大陆有效性测试

# 如何使用
### 1. SwitchHosts 工具

1. 下载 [SwitchHosts](https://github.com/oldj/SwitchHosts)
2. 添加规则：
   - 方案名：TV Hosts
   - 类型：远程
   - URL：`https://cdn.jsdelivr.net/gh/invmy/tradingview-hosts/hosts`
   - 自动更新：12 小时

### 2. 手动更新

1. 获取 hosts：访问 https://cdn.jsdelivr.net/gh/invmy/tradingview-hosts/hosts
2. 更新本地 hosts 文件：
   - Windows：`C:\Windows\System32\drivers\etc\hosts`
   - MacOS/Linux：`/etc/hosts`
3. 刷新 DNS：
   - Windows：`ipconfig /flushdns`
   - MacOS：`sudo killall -HUP mDNSResponder`
   - Linux：`sudo systemd-resolve --flush-caches`

## API 文档

- `GET /hosts` - 获取 hosts 文件内容
- `GET /hosts.json` - 获取 JSON 格式的数据
- `GET /{domain}` - 获取指定域名的实时 DNS 解析结果
- `POST /reset` - 清空缓存并重新获取所有数据（需要 API 密钥）

# 权限问题
- Windows：需要以管理员身份运行
- MacOS/Linux：需要 sudo 权限
