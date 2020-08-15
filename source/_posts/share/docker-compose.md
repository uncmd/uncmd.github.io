---
title: Linux 部署 .NET Core（Docker Compose）
date: 2020-06-13 22:02:56
tags:
  - Linux
  - Compose
  - Docker
categories:
  - 分享
---

> 使用 Docker Compose 部署多容器应用

**运行环境**

* 腾讯云

* CentOS 7.5 64位

* 1核 2GB内存 1M带宽

<!-- more -->

## 简介

多数的现代应用通过多个更小的服务互相协同来组成一个完整可用的应用，比如一个简单的示例应用可能由如下4个服务组成

* Web前端

* 订单管理

* 品类管理

* 后台数据库

部署和管理多个服务是困难的，Docker Compose 通过一个声明式的配置文件描述整个应用，从而使用一条命令完成部署，还可以通过一系列简单的命令实现对其完整生命周期的管理。

## 详解

### 安装 Docker Compose

```bash
yum install docker-compose
```

检查安装情况以及版本

```bash
docker-compose --version
docker-compose version 1.18.0, build 8dd22a9
```

### Compose 文件

Docker compose 使用 YAML 文件来定义多服务的应用，YAML 是 JSON 的一个子集，因此也可以使用 JSON。

Docker Compose 默认使用文件名 `docker-compose.yml`，也可以使用 `-f` 参数指定具体文件

一个简单的 Compose 文件示例

```yaml
version: "3.5"
services:
  web-fe:
    build: .
    command: python app.py
    ports:
      - target: 5000
        published: 5000
    networks:
      - counter-net
    volumes:
      - type: volume
        source: counter-vol
        target: /code
  redis:
    image: "redis:alpine"
    networks:
      counter-net:

networks:
  counter-net:

volumes:
  counter-vol:
```

version是必须指定的，而且总是位于文件的第一行，它定义了 Compose 文件格式的版本。



## 命令