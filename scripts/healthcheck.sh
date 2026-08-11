#!/bin/bash
# ============================================
# 系统健康巡检脚本
# 功能：采集主机与服务健康指标，超阈值标记 ERROR
# 用法：./healthcheck.sh
# 输出：/home/ops/backups/healthcheck.log
# ============================================

# 配置
LOG_FILE="/home/ops/healthcheck/healthcheck.log"
ALERT_DISK=80        # 磁盘使用率告警阈值 %
ALERT_MEM=20         # 可用内存告警阈值 %
ALERT_LOAD=4.0       # 1 分钟负载告警阈值

SERVICES=("nginx" "mysqld")
PORTS=(80 3306)

mkdir -p "$(dirname "$LOG_FILE")"

echo "=======================================" >> "$LOG_FILE"
echo "巡检时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "主机名: $(hostname)" >> "$LOG_FILE"

# 1. 系统负载
LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
echo "Load Average (1min): $LOAD" >> "$LOG_FILE"
if (( $(echo "$LOAD > $ALERT_LOAD" | bc -l) )); then
    echo "  [ERROR] 负载过高: $LOAD (阈值: $ALERT_LOAD)" >> "$LOG_FILE"
fi

# 2. 磁盘使用率
echo "" >> "$LOG_FILE"
echo "--- 磁盘使用率 ---" >> "$LOG_FILE"
df -h | grep -E "^/dev/|^Filesystem" | while read line; do
    echo "  $line" >> "$LOG_FILE"
    USAGE=$(echo "$line" | grep -oP '\d+(?=%)')
    if [ -n "$USAGE" ] && [ "$USAGE" -ge "$ALERT_DISK" ] 2>/dev/null; then
        MOUNT=$(echo "$line" | awk '{print $NF}')
        echo "  [ERROR] 磁盘使用率超阈值: $MOUNT 使用率 ${USAGE}%" >> "$LOG_FILE"
    fi
done

# 3. 内存可用率
echo "" >> "$LOG_FILE"
echo "--- 内存状态 ---" >> "$LOG_FILE"
MEM_TOTAL=$(free -m | awk '/Mem:/{print $2}')
MEM_AVAIL=$(free -m | awk '/Mem:/{print $7}')
MEM_PERCENT=$(echo "scale=2; $MEM_AVAIL * 100 / $MEM_TOTAL" | bc)
echo "  总内存: ${MEM_TOTAL}MB, 可用: ${MEM_AVAIL}MB (${MEM_PERCENT}%)" >> "$LOG_FILE"
if (( $(echo "$MEM_PERCENT < $ALERT_MEM" | bc -l) )); then
    echo "  [ERROR] 可用内存不足: ${MEM_PERCENT}% (阈值: ${ALERT_MEM}%)" >> "$LOG_FILE"
fi

# 4. 服务状态检查
echo "" >> "$LOG_FILE"
echo "--- 服务状态 ---" >> "$LOG_FILE"
for i in "${!SERVICES[@]}"; do
    SVC="${SERVICES[$i]}"
    PORT="${PORTS[$i]}"
    
    # systemd 状态
    if systemctl is-active --quiet "$SVC"; then
        echo "  [OK] $SVC 服务运行中" >> "$LOG_FILE"
    else
        echo "  [ERROR] $SVC 服务未运行" >> "$LOG_FILE"
    fi
    
    # 端口检查
    if ss -lntp | grep -q ":$PORT "; then
        echo "  [OK] $SVC 端口 $PORT 监听中" >> "$LOG_FILE"
    else
        echo "  [ERROR] $SVC 端口 $PORT 未监听" >> "$LOG_FILE"
    fi
done

echo "" >> "$LOG_FILE"
echo "巡检完成" >> "$LOG_FILE"
echo "=======================================" >> "$LOG_FILE"
