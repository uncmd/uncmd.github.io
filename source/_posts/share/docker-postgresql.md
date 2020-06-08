---
title: Linux 部署 .NET Core（Docker 运行 PostgreSQL）
date: 2020-06-8 23:40:40
tags:
  - Linux
  - PostgreSql
  - Docker
categories:
  - 分享
---

> 在 Docker 中运行 PostgreSql

**运行环境**

* 腾讯云

* CentOS 7.5 64位

* 1核 2GB内存 1M带宽

<!-- more -->

## Docker 运行 PostgreSQL

1. 拉取postgreSQL的docker镜像文件

```bash
docker pull postgres
```

2. 创建 docker volume

```bash
docker volume create dv_pgdata
```

3. 启动容器，用 `-v` 指定 postgres 的数据目录映射到上面创建的 dv_pgdata（默认用户名postgres）

```bash
docker run --name uncmd_postgres -v dv_pgdata:/var/lib/postgresql/data -e POSTGRES_PASSWORD=xxxxxx -p 5432:5432 -d postgres:latest
```

4. 查看 docker volume

```bash
docker volume ls
```

5. 查看 volume 信息

```bash
docker inspect dv_pgdata
```

6. 进入镜像

```bash
docker exec -it uncmd_postgres /bin/bash
```

7. 连接数据库

```bash
psql -U postgres
```

8. 查看数据库

```bash
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

9. 数据库操作

```bash
create database auth # 创建数据库 auth
\c auth # 连接到 auth 数据库
\d # 列出当前数据库的所有表
```

10. 在应用程序中设置连接字符串

```json
  "ConnectionStrings": {
    "Default": "Host=your-server-ip; Port=5432; User Id=postgres; Password=xxxxxx; Database=auth;"
  }
```