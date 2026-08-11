const express = require('express');
const mysql = require('mysql2');
const redis = require('redis');

const app = express();
const port = 3000;

const db = mysql.createConnection({
  host: '127.0.0.1',
  user: 'appuser',
  password: 'App_pass_123',
  database: 'myapp'
});

const redisClient = redis.createClient({
  host: '127.0.0.1',
  port: 6379,
  password: 'redis_pass_123'
});
redisClient.on('error', err => console.log('Redis 连接失败:', err.message));

app.get('/', (req, res) => {
  db.query('SELECT NOW() AS now', (err, rows) => {
    const dbTime = err ? '数据库连接失败' : new Date(rows[0].now).toLocaleString();
    res.send('<h1>我的博客服务已上线</h1><p>数据库时间：' + dbTime + '</p>');
  });
});

app.listen(port, () => console.log('App listening on http://127.0.0.1:' + port));
