---
title: CLR via C#
date: 2020-05-20 19:33:40
tags:
  - 读书
  - 笔记
  - C#
categories:
  - 那些年立的Flag
---

本书针对CLR和.NET Framework 进行深入、全面的探讨，并结合实例介绍了如何利用它们进行设计、开发和调试。

[![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/books/clr.jpg)](https://uncmd.github.io/books/CLR/)

<!-- more -->

## 第Ⅰ部分 CLR基础

### 第 1 章 CLR的执行模型

#### CLR是公共语言运行时(Common Language Runtime)

可由多种编程语言使用的“运行时”，核心功能（比如内存管理、程序集加载、安全性、异常处理和线程同步）可由面向CLR的所有语言使用。

可用支持CLR的任何编程语言创建源码文件，然后编译成托管模块，托管模块是PE32或PE32+(64位)文件(PE是Portable Executable可移植执行体的简称)，托管PE文件由四部分组成：

* PE32或PE32+头：标识文件类型(GUI CUI DLL)、生成时间

* CLR头：CLR版本、入口方法元数据token、模块的元数据、资源、强名称

* 元数据：描述源代码中定义的类型和成员、描述源代码引用的类型和成员

* IL：编译器生成的代码，运行时CLR将IL编译成本机CPU指令

JIT(just-in-time)编译器将IL转换成本机(native)CPU指令

方法首次调用时会调用JITCompiler函数将IL代码转换成本机CPU指令，之后再次调用同一方法则会跳过JITCompiler函数，直接执行内存块中的代码。

#### 通用类型系统(Common Type System, CTS)

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

#### 公共语言规范(Common Language Specification, CLS)

它详细定义了一个最小功能集，任何编译器只有支持这个功能集，生成的类型才能兼容由其它符合CLS、面向CLR的语言生成的组件。

![CLR](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/books/clr1-6.jpg)

> 每种语言都提供了CLR/CTS的一个子集以及CLS的一个超集(但不一定是同一个超集)

### 第 2 章 生成、打包、部署和管理应用程序及类型

#### 将类型生成到模块中

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

#### 元数据概述

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

### 第 3 章 共享程序集和强命名程序集

CLR支持两种程序集：弱命名程序集（weakly named assembly）和强命名程序集（strongly named assembly）

两者的区别在于，强命名程序集使用发布者的公钥/私钥进行了签名，这一对密钥允许对程序集进行唯一性标识、保护和版本控制。弱命名程序集只能以私有方式部署，强命名程序集即可私有部署，也可全局部署。

强命名程序集使用以下四个特性唯一标识：文件名（不计扩展名）、版本号、语言文化、公钥

使用SN.exe获取密钥，命令行开关都区分大小写。

```bash
SN -k MyCompany.snk
```

这告诉SN.exe创建 MyCompany.snk 文件，文件中包含二进制形式的公钥和私钥。

#### 全局程序集缓存

由多个应用程序访问的程序集必须放到公认的目录，而且CLR在检测到对该程序集的引用时，必须知道检查该目录。这个公认位置就是**全局程序集缓存(Global Assembly Cache, GAC)**，一般在以下目录：

```
%SystemRoot%\Microsoft.NET\Assembly
```

永远不要将程序集文件手动复制到GAC目录，安装强命名程序集最常用的工具是 GACUtil.exe。建议进行私有而不是全局部署。

CSC.exe 会尝试按顺序在以下目录查找程序集

* 工作目录

* CSC.exe 所在的目录，目录中还包含 CLR 的各种 DLL 文件

* 使用 /lib 编译器开关指定的任何目录

* 使用 LIB 环境变量指定的任何目录

.NET Framework 程序集：生成程序集时从 编译器/CLR 目录加载，运行时从 GAC 加载

## 第Ⅱ部分 设计类型

### 第 4 章 类型基础

* 所有类型都从 System.Object 派生

* 类型转换

* 命名空间和程序集

* 运行时的相互关系

#### 所有类型都从 System.Object 派生

System.Object 类提供了以下4中公共实例方法

* Equals 如果对象具有相同的值，则返回 true。

* GetHashCode 返回对象的值的哈希码。

* ToString 默认返回类型的完整名称（this.GetType().FullName）。

* GetType 返回从 `Type` 派生的一个类型的实例，指出调用 GetType 的那个对象是什么类型。

此外，从 System.Object 派生的类型能访问如下受保护的方法

* MemberwiseClone 这个非虚方法创建类型的新实例，并将新对象的实例字段设与this对象的实例字段完全一致，返回对新实例的引用。

* Finalize 在对象的内存被实际回收之前，会调用这个虚方法。

CLR要求所有对象都用new操作符创建，以下是 new 操作符所做的事情

* 计算类型及其所有基类型中定义的所有实例字段需要的字节数。

* 从托管堆中分配类型要求的字节数，从而分配对象的内存，分配的所有字节都设为零(0)。

* 初始化对象的“类型对象指针”和“同步块索引”成员。

* 调用类型的实例构造器，传递在 new 调用中指定的实参

#### 类型转换

CLR 最重要的特性之一就是类型安全

is 操作符检查对象是否兼容于指定类型

as 操作符返回转换后的对象，如果不能转换则返回 null

#### 命名空间和程序集

**命名空间**对相关类型进行逻辑分组，使名称变得更长，更可能具有唯一性。

命名空间和程序集不一定相关，不同程序集可能存在相同名称空间。

#### 运行时的相互关系

线程创建时会分配到1MB的栈，栈空间用于向方法传递实参，方法内部定义的局部变量也在栈上。

### 第 5 章 基元类型、引用类型和值类型

* 编程语言的基元类型

* 引用类型和值类型

* 值类型的装箱和拆箱

* 对象哈希码

* dynamic 基元类型

#### 编程语言的基元类型

编译器直接支持的数据类型称为**基元类型**(primitive type)。基元类型直接映射到Framework 类库(FCL)中存在的类型。

例如，C#的 `int` 直接映射到 `System.Int32` 类型。

C#编译器支持与类型转换、字面值以及操作符有关的模式。只有在转换“安全”的时候，C#才允许隐式转换，“安全”是指不会发生数据丢失的情况。

C#总是对转换结果进行截断，而不进行向上取整。

CLR提供add/add.ovf, sub/sub.ovf, mul/mul.ovf和conv/conv.ovf IL指令，前者不执行溢出检查，后者在发生溢出时抛出 `System.OverflowException` 异常。

C#溢出检查默认关闭，编译器的 `/checked+` 开关全局控制是否溢出检查，`checked` 和 `uncheck` 操作符局部控制是否溢出检查，如：

```csharp
UInt32 invalid = unchecked((UInt32) (-1));  // OK

Byte b = 100;
b = checked((Byte) (b + 200));  // 抛出 OverflowException 异常

checked{
  Byte b = 100;
  b = checked((Byte) (b + 200));
}
```

#### 引用类型和值类型

CLR 支持**引用类型**和**值类型**。引用类型总是从托管堆分配，C#的 `new` 操作符返回对象内存地址，使用引用类型必须留意性能问题

* 内存必须从托管堆分配

* 堆上分配的每个对象都有一些额外成员，这些成员必须初始化

* 对象中的其它字节（为字段而设）总是设为零

* 从托管堆分配对象时，可能强制执行一次垃圾回收

值类型的实例一般在线程栈上分配，派生自 `System.ValueType`，所有值类型都隐式密封，目的是防止将值类型用作其它引用类型或值类型的基类型。



### 第 6 章 类型和成员基础

### 第 7 章 常量和字段

### 第 8 章 方法

### 第 9 章 参数

### 第 10 章 属性

### 第 11 章 事件

### 第 12 章 泛型

### 第 13 章 接口