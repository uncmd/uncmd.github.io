---
title: EntityFramworkCore相关
date: 2020-05-15 21:41:40
tags:
  - ORM
categories:
  - 微服务
---

> Entity Framework (EF) Core 是轻量化、可扩展、开源和跨平台版的常用 Entity Framework 数据访问技术。

> 官网文档：https://docs.microsoft.com/zh-cn/ef/core/

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/efcore.jpg)

<!-- more -->

## EntityFramworkCore介绍

EF Core 可用作对象关系映射程序 (O/RM)，以便于 .NET 开发人员能够使用 .NET 对象来处理数据库，这样就不必经常编写大部分数据访问代码了。

## EntityFramworkCore使用

### 数据迁移常用命令：

安装ef工具

```bash
dotnet tool install -g dotnet-ef
```

创建迁移

```bash
Add-Migration InitialCreate

dotnet ef migrations add InitialCreate
```

更新数据库

```bash
Update-Database

dotnet ef database update
```

删除迁移

```bash
Remove-Migration

dotnet ef migrations remove
```

还原迁移

```bash
Update-Database LastGoodMigration

dotnet ef database update LastGoodMigration
```

生成SQL脚本

```bash
Script-Migration

dotnet ef migrations script
```

在运行时应用迁移

```csharp
myDbContext.Database.Migrate()
```

## EntityFramworkCore使用Oracle

从NuGet安装包：Oracle.EntityFramworkCore

Oracle数据库的默认事务级别
在PreInitialize事件中设置工作单元的默认事务级别为 ReadCommitted

> Configuration.UnitOfWork.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;