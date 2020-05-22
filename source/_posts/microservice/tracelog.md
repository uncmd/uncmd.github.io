---
title: 分布式追踪/日志
date: 2020-05-1 9:41:40
tags:
  - 日志
categories:
  - 微服务
---

## 分布式追踪 SkyWalking

## 分布式日志 Exceptionless

### Windows下安装ElasticSearch及工具

> Elasticsearch 是一个分布式、可扩展、实时的搜索与数据分析引擎。 它能从项目一开始就赋予你的数据以搜索、分析和探索的能力，这是通常没有预料到的。 Elasticsearch 不仅仅只是全文搜索，我们还将介绍结构化搜索、数据分析、复杂的语言处理、地理位置和对象间关联关系等。

#### 安装ElasticSearch

* 版本：7.4.0

* [下载地址](https://elasticsearch.cn/download/)

* 解压到本地目录

* 运行bin目录下的elasticsearch.bat文件

* 浏览器访问 http://localhost:9200/ ，如果出现如下则服务启动成功

```json
{
  "name" : "DGCACOAHVD079",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "X5brr9MaRMmcnn3jqlir1w",
  "version" : {
    "number" : "7.4.0",
    "build_flavor" : "default",
    "build_type" : "zip",
    "build_hash" : "22e1767283e61a198cb4db791ea66e3f11ab9910",
    "build_date" : "2019-09-27T08:36:48.569419Z",
    "build_snapshot" : false,
    "lucene_version" : "8.2.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

 **把Elasticsearch安装为Windows服务**

进入bin目录下执行:

```
安装Elasticsearch服务
elasticsearch-service.bat install

删除已安装的Elasticsearch服务（如果启动则停止服务）
elasticsearch-service.bat remove

启动Elasticsearch服务（如果已安装）
elasticsearch-service.bat start

停止服务（如果启动）
elasticsearch-service.bat stop

启动GUI来管理已安装的服务
elasticsearch-service.bat manager
```

#### 安装Kibana

> Kibana 是通向 Elastic 产品集的窗口。 它可以在 Elasticsearch 中对数据进行视觉探索和实时分析。此处简单介绍，稍后会专门写一篇博客介绍Kibana及其用法

* 版本：7.4.0

* [下载地址](https://elasticsearch.cn/download/)

* 解压到本地目录

* 打开 config/kibana.yml，并修改其中elasticsearch.url的值，此处的URL要修改成ElasticSearch启动的URL，默认值为 http://localhost:9200

* 使用 cmd 进入Kibana的bin目录，然后运行kibana.bat文件

* 打开浏览器，访问 http://localhost:5601 即可。如果该端口被占用了，在启动的cmd控制台有显示访问的地址，复制访问即可。

 **把Kibana安装为Windows服务**

 Kibana没有提供安装Windows服务的功能，我们需要借助 nssm.exe 把Kibana安装为Windows服务。

 用命令行执行 nssm.exe install，弹出安装对话框

 * 把 Application Path设置为Kibana安装目录\bin\kibana.bat
 
 * Startup directory设置为安装目录\bin

 * 参数为空
 
 * 服务名称为 Kibana-7.4.0
## log4net日志写到Oracle数据库

1、在数据库中建表

```
create table LOG_INFO
(
  logid        NUMBER,
  logdate      DATE,
  logthread    VARCHAR2(255),
  loglevel     VARCHAR2(50),
  loglogger    VARCHAR2(255),
  logmessage   VARCHAR2(4000),
  logexception VARCHAR2(2000)
)
```

2、在log4net.config添加一个写入Oracle数据库的Appender配置

> Oracle.ManagedDataAccess.dll 的版本与公钥必须与项目引用的一致

 在 web.config 中添加 

```
<add key="log4net.Internal.Debug" value="true "/> 
```

可以在输出窗口查看log4net本身的日志输出，便于调试

```
    <logger name="logoracle">
      <level value="INFO" />
      <appender-ref ref="AdoNetAppender_Oracle" />
    </logger>

    <appender name="AdoNetAppender_Oracle" type="log4net.Appender.AdoNetAppender">
      <connectionType value="Oracle.ManagedDataAccess.Client.OracleConnection, Oracle.ManagedDataAccess, Version=4.122.19.1, Culture=neutral, PublicKeyToken=89b483f429c47342" />
      <!--<connectionString value="Data Source = //xxx:1521/xxx;User ID = xxx;Password = xxx" />-->
      <connectionString value="Data Source = (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = xxx)(PORT = 1521))(CONNECT_DATA = (SERVICE_NAME = xxx)));User ID = xxx;Password = xxx" />
      <commandText value="INSERT INTO LOG_INFO (LOGDATE,LOGTHREAD,LOGLEVEL,LOGLOGGER,LOGMESSAGE,LOGEXCEPTION) VALUES (:log_date,:thread,:log_level,:logger,:message,:exception)" />
      <bufferSize value="1" />
       <parameter>
        <parameterName value=":log_date" />
        <dbType value="DateTime" />
        <layout type="log4net.Layout.RawTimeStampLayout" />
      </parameter>
      <parameter>
          <parameterName value=":thread" />
          <dbType value="String" />
          <size value="255" />
          <layout type="log4net.Layout.PatternLayout">
              <conversionPattern value="%thread" />
          </layout>
      </parameter>
      <parameter>
          <parameterName value=":log_level" />
          <dbType value="String" />
          <size value="50" />
          <layout type="log4net.Layout.PatternLayout">
              <conversionPattern value="%level" />
          </layout>
      </parameter>
      <parameter>
          <parameterName value=":logger" />
          <dbType value="String" />
          <size value="255" />
          <layout type="log4net.Layout.PatternLayout">
              <conversionPattern value="%logger" />
          </layout>
      </parameter>
      <parameter>
          <parameterName value=":message" />
          <dbType value="String" />
          <size value="4000" />
          <layout type="log4net.Layout.PatternLayout">
              <conversionPattern value="%message" />
          </layout>
      </parameter>
      <parameter>
          <parameterName value=":exception" />
          <dbType value="String" />
          <size value="2000" />
          <layout type="log4net.Layout.ExceptionLayout" />
      </parameter>
    </appender>
```

3、使用Oracle配置写日志

```
var logger = log4net.LogManager.GetLogger("logoracle")
logger.Info("Info");
```