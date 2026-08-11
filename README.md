# 项目一：小型生产环境部署

## 项目简介
在 CentOS 7 上部署 Nginx + Node.js 应用 + MySQL + Redis，
配置 HTTPS、反向代理、日志、定时备份与健康巡检。

## 环境
- 操作系统：CentOS 7
- 服务：Nginx 1.x / Node.js 18 / MySQL 8.0 / Redis
- 脚本：Shell

## 项目结构
project/<br>
├── app/                 # 应用代码（Node.js + Express）<br>
│   ├── app.js<br>
│   └── package.json<br>
├── scripts/<br>
│   ├── backup.sh        # MySQL 备份脚本<br>
│   └── healthcheck.sh   # 系统健康巡检脚本<br>
├── configs/<br>
│   ├── nginx-myapp.conf # Nginx 反向代理 + HTTPS 配置<br>
│   └── myapp.service    # systemd 单元文件<br>
├── docs/                # 架构图、部署文档、故障复盘<br>
└── README.md<br>

## 快速部署
1. 安装依赖并启动 mysql/redis/nginx
2. 部署应用：node app.js（或 systemctl start myapp）
3. 配置 Nginx 反向代理与 HTTPS
4. 测试备份与巡检脚本

## 故障案例
见 docs/ 目录下的故障复盘记录。
