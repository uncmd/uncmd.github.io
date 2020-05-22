---
title: 定时任务
date: 2020-05-5 15:41:40
tags:
  - 调度
categories:
  - 微服务
---

## 定时任务介绍

定时任务用于周期性执行指定任务

## Hangfire使用

使用 Hangfire.HttpJob 扩展库，Job和接口分离

参考：

[分布式Job系统Hangfire](https://www.cnblogs.com/Leo_wl/p/10995388.html#_label12)

## Quatrz .NET

## NuGet 服务器搭建

### 在 Windows 上搭建

此方式更为简单，因为nuget上有现在的nuget.server这包，就是用于做这件事情的。步骤如下（此 NuGet 包不支持 .net core版本）:

* 创建一个mvc 项目（空） 此项目必须的 .net Framework版本必须>=4.6。
* 引入nuget.server这个nuget包
* 更改Web.config配置

| 节点名	| 说明 |
| --- | --- |
| apiKey |	nuget.server的密钥配置，用于Push和delete包
| packagesPath |	nuget.server中的包存放路径

* 运行此项目

### 常用命令

#### dotnet nuget delete 

> 从服务器删除或取消列出包。

```bash
dotnet nuget delete [<PACKAGE_NAME> <PACKAGE_VERSION>] [--force-english-output] [--interactive] [-k|--api-key] [--no-service-endpoint]
    [--non-interactive] [-s|--source]
dotnet nuget delete [-h|--help]
```

示例：

```bash
dotnet nuget delete Microsoft.AspNetCore.Mvc 1.0
```

#### dotnet nuget locals

> 清除或列出本地 NuGet 资源。

```bash
dotnet nuget locals <CACHE_LOCATION> [(-c|--clear)|(-l|--list)] [--force-english-output]
dotnet nuget locals [-h|--help]
```

示例：

```bash
dotnet nuget locals –l all
```

#### dotnet nuget push

> 将包推送到服务器，并将其发布。

```bash
dotnet nuget push [<ROOT>] [-d|--disable-buffering] [--force-english-output] [--interactive] [-k|--api-key] [-n|--no-symbols]
    [--no-service-endpoint] [-s|--source] [-sk|--symbol-api-key] [-ss|--symbol-source] [-t|--timeout]
dotnet nuget push [-h|--help]
```

示例：

```bash
dotnet nuget push foo.nupkg -k 4003d786-cc37-4004-bfdf-c4f3e8ef9b3a

dotnet nuget push foo.nupkg -k 4003d786-cc37-4004-bfdf-c4f3e8ef9b3a -s https://customsource/

dotnet nuget push *.nupkg
```


参考：

- https://docs.microsoft.com/zh-cn/dotnet/core/tools/dotnet-nuget-delete

- https://www.cnblogs.com/cqhaibin/p/8051834.html#sectionthree