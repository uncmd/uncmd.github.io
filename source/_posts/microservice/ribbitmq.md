---
title: RibbitMQ
date: 2020-05-16 23:41:40
tags:
  - MQ
categories:
  - 微服务
---

## RibbitMQ介绍

RabbitMQ是实现了高级消息队列协议（AMQP）的开源消息代理软件（亦称面向消息的中间件）。RabbitMQ服务器是用Erlang语言编写的，而集群和故障转移是构建在开放电信平台框架上的。所有主要的编程语言均有与代理接口通讯的客户端库。

[RibbitMQ官网](https://www.rabbitmq.com/)

## RibbitMQ使用

常用命令

> rabbitmqctl.bat stop

> rabbitmqctl.bat status

> rabbitmq-plugins enable rabbitmq_management

> 默认UI地址：http://localhost:15672


连接字符串为：amqp://guest:guest@172.20.212.164:5672/

AuthenticationFailureException: ACCESS_REFUSED - Login was refused using authentication mechanism PLAIN

原因如下：账号guest具有所有的操作权限，并且又是默认账号，出于安全因素的考虑，guest用户只能通过localhost登陆使用，并建议修改guest用户的密码以及新建其他账号管理使用rabbitmq(该功能是在3.3.0版本引入的)。

解决一：改为 amqp://guest:guest@localhost:5672/

解决二：新建了一个用户admin，密码也是admin，并开启了所有权限，连接字符串改为 amqp://admin:admin@172.20.212.164:5672/