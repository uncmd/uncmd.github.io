---
title: PostgreSQL
date: 2020-05-9 22:21:40
tags:
  - 数据库
categories:
  - 微服务
---

## PostgreSQL介绍

PostgreSQL是一种特性非常齐全的自由软件的对象-关系型数据库管理系统（ORDBMS），是以加州大学计算机系开发的POSTGRES，4.2版本为基础的对象关系型数据库管理系统。POSTGRES的许多领先概念只是在比较迟的时候才出现在商业网站数据库中。PostgreSQL支持大部分的SQL标准并且提供了很多其他现代特性，如复杂查询、外键、触发器、视图、事务完整性、多版本并发控制等。同样，PostgreSQL也可以用许多方法扩展，例如通过增加新的数据类型、函数、操作符、聚集函数、索引方法、过程语言等。另外，因为许可证的灵活，任何人都可以以任何目的免费使用、修改和分发PostgreSQL。

[PostgreSQL官网](https://www.postgresql.org/)

## PostgreSQL使用

用csv导入数据的时候报invalid byte sequence for encoding "UTF8" 0xd2 0xc6错误
原因是csv的编码不是UTF8
解决方法：用Notepad++打开csv文件，然后选择编码-转为UTF-8编码

csv文件的列名要和表名一致

-- 序列重置到1000
alter sequence sequence_name restart with 1000;

-- 下一序列值
SELECT nextval('sequence_name');

被引用表(referenced table)中的被引用列(referenced column)必须是一个非延迟的唯一约(unique key)束或者主键约束(primary key)