---
title: Jenkins
date: 2020-05-16 23:41:40
tags:
  - CI/CD
categories:
  - 微服务
---

## Jenkins介绍

Jenkins是一个开源软件项目，是基于Java开发的一种持续集成工具，用于监控持续重复的工作，旨在提供一个开放易用的软件平台，使软件的持续集成变成可能。

[Jenkins官网](https://jenkins.io/zh/)

## Jenkins使用

Jenkin的Execute Shell构建步骤的最后一个命令的退出代码决定了构建步骤的成功/失败
RoboCopy如果所有文件都已成功复制，则返回代码为1. 除了0以外的任何内容都被构建步骤报告为失败
https://stackoverflow.com/questions/33358242/build-step-windows-powershell-marked-build-as-failure-why


部署到IIS上的ASP.NET Core项目，在更新的时候会进程占用的错误
http://m.mamicode.com/info-detail-2709112.html
https://docs.microsoft.com/zh-cn/aspnet/core/host-and-deploy/iis/?view=aspnetcore-2.2#locked-deployment-files


IIS构建配置示例：

编译

```bash
dotnet build
```

运行测试

```bash
dotnet test microservices\AssemblyReport\test\AssemblyReport.Tests\AssemblyReport.Tests.csproj
```

发布

```bash
cd microservices/AssemblyReport/src/AssemblyReport.Web.Host

dotnet publish -c Release -o D:\Jenkins\BuildData\Workspace\Publish\AssemblyReport
```

压缩备份

```bash
rar a -agYYYYMMDDHHMMSS -x*\App_Data D:\BackFile\AssemblyReport\Service D:\AssemblyReport21031
```

app_offline.htm转发请求，防止文件被占用，可以不停止服务发布

```bash
xcopy D:\app_offline.htm D:\AssemblyReport21031
```

复制发布文件到IIS目录，排除json config pdb文件，失败重试3次，每次重试间隔1秒

```bash
robocopy D:\Jenkins\BuildData\Workspace\Publish\AssemblyReport D:\AssemblyReport21031 /xf *.json *.config *.pdb /R:3 /W:1
```

删除app_offline.htm文件，恢复正常访问

```bash
del D:\AssemblyReport21031\app_offline.htm
```

退出

```bash
exit 0
```
