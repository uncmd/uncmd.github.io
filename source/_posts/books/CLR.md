---
title: CLR via C#
date: 2020-05-16 23:41:40
tags:
  - 读书
  - 笔记
  - C#
categories:
  - 那些年立的Flag
---

本书针对CLR和.NET Framework 进行深入、全面的探讨，并结合实例介绍了如何利用它们进行设计、开发和调试。

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/clr.jpg)

<!-- more -->

## 第一章 CLR的执行模型

### CLR是公共语言运行时(Common Language Runtime)

可由多种编程语言使用的“运行时”，核心功能（比如内存管理、程序集加载、安全性、异常处理和线程同步）可由面向CLR的所有语言使用。

可用支持CLR的任何编程语言创建源码文件，然后编译成托管模块，托管模块是PE32或PE32+(64位)文件(PE是Portable Executable可移植执行体的简称)，托管PE文件由四部分组成：

* PE32或PE32+头：标识文件类型(GUI CUI DLL)、生成时间

* CLR头：CLR版本、入口方法元数据token、模块的元数据、资源、强名称

* 元数据：描述源代码中定义的类型和成员、描述源代码引用的类型和成员

* IL：编译器生成的代码，运行时CLR将IL编译成本机CPU指令

JIT(just-in-time)编译器将IL转换成本机(native)CPU指令

方法首次调用时会调用JITCompiler函数将IL代码转换成本机CPU指令，之后再次调用同一方法则会跳过JITCompiler函数，直接执行内存块中的代码。

### 通用类型系统(Common Type System, CTS)

类型向应用程序和其他类型公开了功能，通过类型，用一种编程语言写的代码能与用另一种编程语言写的代码沟通。

一个类型可用包含零个或多个成员

* 字段(Field)

* 方法(Method)

* 属性(Property)

* 事件(Event)

类型可见性

* private：只能由同一个类中的其他成员访问

* family(C# protected)：可由派生类型访问，不管是否在同一个程序集

* family and assembly(C#未提供这种访问控制)：可由派生类型访问，必须在同一个程序集

* assembly(C# internal)：可由同一程序集的任何代码访问

* family or assembly(C# protected internal)：任何程序集的派生类型访问，也可由同一程序集的任何类型访问

* public：可由任何程序集中的任何代码访问

### 公共语言规范(Common Language Specification, CLS)

它详细定义了一个最小功能集，任何编译器只有支持这个功能集，生成的类型才能兼容由其它符合CLS、面向CLR的语言生成的组件。

![CLR](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/clr1-6.jpg)

> 每种语言都提供了CLR/CTS的一个子集以及CLS的一个超集(但不一定是同一个超集)

## 第二章 生成、打包、部署和管理应用程序及类型

### 将类型生成到模块中

```
csc.exe /out:Program.exe /t:exe /r:MSCorLib.dll Program.cs
```

**响应文件**

响应文件是包含一组编译器命令行开关的文本文件，扩展名为.rsp，在命令行中用@符号指定响应文件。CSC.exe运行是会在CSC.exe所在的目录查找全局CSC.rsp文件，相同开关优先级为命令行显示指定>本地响应文件>全局响应文件。

.NET Framework安装时会在%SystemRoot%\Microsoft .NET\Framework64\vX.X.X目录中安装默认全局CSC.rsp文件，如v4.0.30319版本CSC.rsp文件内容如下：

```
# This file contains command-line options that the C#
# command line compiler (CSC) will process as part
# of every compilation, unless the "/noconfig" option
# is specified. 

# Reference the common Framework libraries
/r:Accessibility.dll
/r:Microsoft.CSharp.dll
/r:System.Configuration.dll
/r:System.Configuration.Install.dll
/r:System.Core.dll
/r:System.Data.dll
/r:System.Data.DataSetExtensions.dll
/r:System.Data.Linq.dll
/r:System.Data.OracleClient.dll
/r:System.Deployment.dll
/r:System.Design.dll
/r:System.DirectoryServices.dll
/r:System.dll
/r:System.Drawing.Design.dll
/r:System.Drawing.dll
/r:System.EnterpriseServices.dll
/r:System.Management.dll
/r:System.Messaging.dll
/r:System.Runtime.Remoting.dll
/r:System.Runtime.Serialization.dll
/r:System.Runtime.Serialization.Formatters.Soap.dll
/r:System.Security.dll
/r:System.ServiceModel.dll
/r:System.ServiceModel.Web.dll
/r:System.ServiceProcess.dll
/r:System.Transactions.dll
/r:System.Web.dll
/r:System.Web.Extensions.Design.dll
/r:System.Web.Extensions.dll
/r:System.Web.Mobile.dll
/r:System.Web.RegularExpressions.dll
/r:System.Web.Services.dll
/r:System.Windows.Forms.Dll
/r:System.Workflow.Activities.dll
/r:System.Workflow.ComponentModel.dll
/r:System.Workflow.Runtime.dll
/r:System.Xml.dll
/r:System.Xml.Linq.dll
```

指定/noconfig命令行开关，编译器将忽略本地和全局CSC.rsp文件

### 元数据概述

PE文件中的元数据是由几个表构成的二进制数据块，有三种表，分别是定义表(definition table)、引用表(reference table)和清单表(mainfest table)

常用的元数据定义表

* ModuleDef：包含文件模块文件名称和扩展名（不含路径），以及模块版本ID（编译器创建的GUID）

* TypeDef：模块定义的每个类型在这个表中都有一个记录项

* MethodDef：模块定义的每个方法都在这个表中有一个记录项

* FieldDef：模块定义的每个字段都在这个表中有一个记录项

* ParamDef：模块定义的每个参数都在这个表中有一个记录项

* PropertyDef：模块定义的每个属性都在这个表中有一个记录项

* EventDef：模块定义的每个事件都在这个表中有一个记录项

常用的元数据引用表

* AssemblyRef

* ModuleRef

* TypeRef

* MemberRef

可以用 ILDasm.exe（IL 反汇编器）查看元数据表

```
ILDasm Program.exe
```

## 第三章 共享程序集和强命名程序集

CLR支持两种程序集：弱命名程序集（weakly named assembly）和强命名程序集（strongly named assembly）

两者的区别在于，强命名程序集使用发布者的公钥/私钥进行了签名，这一对密钥允许对程序集进行唯一性标识、保护和版本控制。弱命名程序集只能以私有方式部署，强命名程序集即可私有部署，也可全局部署。

强命名程序集使用以下四个特性唯一标识：文件名（不计扩展名）、版本号、语言文化、公钥