#!/bin/bash
# ============================================
# MySQL 数据库定时备份脚本
# 功能：全量备份指定数据库，保留最近 N 天
# 用法：./backup.sh
# ============================================

# 配置项
DB_USER="root"
DB_PASS="Aibowei20050108."
DB_NAME="myapp"
BACKUP_DIR="/home/ops/backups"
RETENTION_DAYS=7
DATE_TAG=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="/home/ops/backups/backup.log"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 执行备份
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE_TAG}.sql"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始备份: $DB_NAME" >> "$LOG_FILE"

if mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>> "$LOG_FILE"; then
    gzip "$BACKUP_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份完成: ${BACKUP_FILE}.gz" >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份失败: $DB_NAME" >> "$LOG_FILE"
    exit 1
fi

# 清理过期备份
find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +$RETENTION_DAYS -exec rm {} \;

# 输出当前保留的备份
CURRENT=$(ls -lh "${BACKUP_DIR}/${DB_NAME}_*.sql.gz" 2>/dev/null | wc -l)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 当前保留 ${CURRENT} 个备份文件" >> "$LOG_FILE"

echo "备份完成！文件: ${BACKUP_FILE}.gz"
