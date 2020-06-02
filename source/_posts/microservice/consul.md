---
title: 服务注册/发现Consul
date: 2020-05-3 23:41:40
tags:
  - 服务注册
categories:
  - 微服务
---

> 自动化网络配置，发现服务并启用跨任何云或运行时的安全连接。

> 官网：https://www.consul.io/

[![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/consul.jpg)](https://uncmd.github.io/microservice/consul/)

<!-- more -->

## Consul介绍

Consul是一种服务发现和配置工具。Consul具有分布式，高可用性和极高的可扩展性。

Consul提供了几个关键功能：

* 服务发现 - 使用简单的服务来注册自己并通过DNS或HTTP接口发现其他服务。也可以注册SaaS提供商等外部服务。

* 运行状况检查 - 运行状况检查使Consul能够快速向运营商发出有关群集中任何问题的警报 与服务发现的集成可防止将流量路由到不健康的主机，并启用服务级别的断路器。

* 密钥/值存储 - 灵活的密钥/值存储可以存储动态配置，功能标记，协调，领导者选举等。简单的HTTP API使其易于在任何地方使用。

* 多数据中心 - Consul可以识别数据中心，并且可以支持任意数量的区域而无需复杂的配置。

* 服务分段 - Consul Connect通过自动TLS加密和基于身份的授权实现安全的服务到服务通信。

### 快速开始

可以在Consul网站上查看广泛的快速入门：

<https://www.consul.io/intro/getting-started/install.html>

### 文档

可以在Consul网站上查看完整、全面的文档：

<https://www.sonsul.io/docs>

参考资料：

[Consul使用手册](https://blog.csdn.net/liuzhuchen/article/details/81913562)

## Consul使用

创建名称为Consul的Windows服务，并读取D:\Consul\configs文件夹中的配置：

> sc create "Consul" binPath= "D:\Consul\consul.exe agent -config-dir D:\Consul\configs" start= auto

已注册的服务即使关闭了也不会从Consul移除，需要手动移除无效的服务，-id参数后面是服务的ID：

> consul services deregister -id=ServiceId

Consul启动读取配置文件夹会按名称顺序读取，如先读取a.json，然后读取b.json，如果a、b中存在相同的配置项，则 b 会覆盖 a 的值。

> 特别注意：

> 当服务独立部署的时候可以正常注册到 Consul，但是部署到 IIS 后，服务直到第一次接受请求才会注册。当所有服务都是通过网关请求时，网关首先要从 Consul 获取服务信息，但是服务启动后未注册导致网关无法获取服务信息，请求失败。

> 解决这个问题有两种思路，一是IIS启动和回收时立即请求一次服务（预加载），二是使用定时服务一直请求服务。

> 第一种方式可参考微软官方方案：[IIS 8.0 Application Initialization](https://docs.microsoft.com/zh-cn/iis/get-started/whats-new-in-iis-8/iis-80-application-initialization)，几次尝试未成功后我使用了第二种方式，使用调度一直请求服务.

Consul服务配置示例：

```json
{
	"datacenter": "ctl1",
	"node_name": "node1",
	"data_dir": "data",
	"performance": {
	  "raft_multiplier": 3
	},
	"server": true,
	"ui": true,
	"ports":{
		"http": 8500,
		"dns": 8600,
		"grpc": 8400,
		"serf_lan": 8301,
		"serf_wan": 8302,
		"server": 8300
	},
	"log_level": "TRACE",
	"log_file": "logs/",
	"bootstrap_expect": 1,
	"client_addr": "0.0.0.0"
}
```
> 注意："client_addr": 默认是127.0.0.1所以不对外提供服务，如果你要对外提供服务改成0.0.0.0。如果是默认127.0.0.1，无法从外部访问Consul的UI界面

从配置文件注册服务：

```json
{
  "services": [
	{
      "id": "service1",
      "name": "ConsulServer",
      "tags": [
        "primary"
      ],
      "address": "localhost",
      "port": 8282,
      "checks": [
        {
        "http": "http://localhost:8282/Server.svc",
        "interval": "10s",
        "timeout": "1s"
        }
      ]
    },
	{
      "id": "service2",
      "name": "ConsulServer",
      "tags": [
        "primary"
      ],
      "address": "localhost",
      "port": 8283,
      "checks": [
        {
        "http": "http://localhost:8283/Server.svc",
        "interval": "10s",
        "timeout": "1s"
        }
      ]
    }
  ]
}
```

acl_token：agent会使用这个token和consul server进行请求
acl_ttl：控制TTL的cache，默认是30s
addresses：一个嵌套对象，可以设置以下key：dns、http、rpc
advertise_addr：等同于-advertise
bootstrap：等同于-bootstrap
bootstrap_expect：等同于-bootstrap-expect
bind_addr：等同于-bind
ca_file：提供CA文件路径，用来检查客户端或者服务端的链接
cert_file：必须和key_file一起
check_update_interval：
client_addr：等同于-client
datacenter：等同于-dc
data_dir：等同于-data-dir
disable_anonymous_signature：在进行更新检查时禁止匿名签名
enable_debug：开启debug模式
enable_syslog：等同于-syslog
encrypt：等同于-encrypt
key_file：提供私钥的路径
leave_on_terminate：默认是false，如果为true，当agent收到一个TERM信号的时候，它会发送leave信息到集群中的其他节点上。
log_level：等同于-log-level  "trace”, “debug”, “info”, “warn”, 和 “err”
node_name:等同于-node 
ports：这是一个嵌套对象，可以设置以下key：dns(dns地址：8600)、http(http api地址：8500)、rpc(rpc:8400)、serf_lan(lan port:8301)、serf_wan(wan port:8302)、server(server rpc:8300) 
protocol：等同于-protocol
rejoin_after_leave：等同于-rejoin
retry_join：等同于-retry-join
retry_interval：等同于-retry-interval 
server：等同于-server
syslog_facility：当enable_syslog被提供后，该参数控制哪个级别的信息被发送，默认Local0
ui_dir：等同于-ui-dir