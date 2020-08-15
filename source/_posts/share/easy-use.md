---
title: 提升体验
date: 2020-08-15 21:56:40
tags:
  - 日常
categories:
  - 分享
---

> 提升体验的日常收集

<!-- more -->

## 递归删除文件夹下所有 `bin` 和 `obj` 目录

### Windows 的 `cmd` 命令工具

```bash
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S bin') DO RMDIR /S /Q "%%G"
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S obj') DO RMDIR /S /Q "%%G"
```

### Windows 的 Powershell

```bash
Get-ChildItem .\ -include bin,obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse }
```

### bash类型的命令行工具（git bash 或者 Linux/OS X shells）

```bash
find . -iname "bin" -o -iname "obj" | xargs rm -rf
```