---
title: 使用Kafka协议上传日志到阿里云日志服务
date: 2020-07-24 19:52:30
tags:
  - kafka
  - 消息队列
  - 日志
  - 阿里云
categories:
  - 阿里云
  - 分享
---

## 简介

最近入职新公司，公司准备接入阿里云的日志服务。公司服务器是自建的，不是云服务器，阿里云日志服务提供的日志采集代理Logtail用于采集阿里云ECS、自建IDC、其他云厂商等服务器上的日志，具有以下优势

* 基于日志文件，无侵入式采集日志。您无需修改应用程序代码，且采集日志不会影响您的应用程序运行。

* 除采集文本日志外，还支持采集binlog、http数据、容器日志等。

* 对容器支持友好，支持标准容器、swarm集群、Kubernetes集群等容器集群的数据采集。

* 稳定处理日志采集过程中的各种异常。当遇到网络异常、服务端异常等问题时会采用主动重试、本地缓存数据等措施保障数据安全。

* 基于日志服务的集中管理能力。安装Logtail后，只需要在日志服务上配置机器组、Logtail采集配置等信息即可。

* 完善的自我保护机制。为保证运行在服务器上的Logtail，不会明显影响您服务器上其他服务的性能，Logtail在CPU、内存及网络使用方面都做了严格的限制和保护机制。

但是Logtail采集需要服务器连接外网，而且网络要稳定，目前不是所有服务器都连了外网，故需要换一种采集方式。

阿里云日志服务还支持Web Tracking、Kafka协议上传、Syslog协议上传、Logstash采集、SDK采集等采集方式，因为考虑到旧应用的兼容性，最终主要采用Kafka协议上传日志方式采集日志。

可以使用各类Kafka Producer SDK或采集工具来采集日志，并通过Kafka协议上传到日志服务。

总体的日志采集架构如下

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/logserver/kafka-logserver.jpg)

如上，旧应用使用采集工具采集文本日志发往Kafka Cluster，不需要改代码。新应用使用Kafka Producer SDK方式，将输出的日志发往Kafka Cluster。日志消费服务将Kafka Cluster中要发往日志服务的日志上传到阿里云日志服务。

也可以使用Logtail/Logstash/SDK等方式采集日志，然后直接上传到日志服务，缺点是应用所在的服务器必须能连接上阿里云日志服务，也就是需要外网。

下面将一步一步介绍上述架构的实现

## 安装Kafka（Windows）

* [下载Kafka](http://kafka.apache.org/downloads)，当前最新版本为2.5.0，下载二进制文件并解压缩到一个不含中文的目录

* 启动服务器

Kafka 使用 ZooKeeper 如果你还没有ZooKeeper服务器，你需要先启动一个ZooKeeper服务器。 您可以通过与kafka打包在一起的便捷脚本来快速简单地创建一个单节点ZooKeeper实例。

在解压缩文件夹打开命令行

```bash
bin/windows/zookeeper-server-start.bat config/zookeeper.properties
```

> 遇到语法错误的报错，是因为目录层级太深或者是目录名字太长导致的，把Kafka的目录放到D盘根目录下就OK了。

新开一个命令行，启动Kafka服务

```bash
bin/windows/kafka-server-start.bat config/server.properties
```

Kafka服务的默认端口为9092

* 创建一个topic

```bash
bin/windows/kafka-topics.bat --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```

运行list命令查看topic

```bash
bin/windows/kafka-topics.bat --list --zookeeper localhost:2181
```

* 发送消息

```bash
bin/windows/kafka-console-producer.bat --broker-list localhost:9092 --topic test
This is a message
This is another message
```

* 启动一个 consumer

```bash
bin/windows/kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic test --from-beginning
```

命令执行过程入下图

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/logserver/kafka-bash.jpg)

这样一个简单的Kafka就安装好了，后面基于本地Kafka开发

## Kafka Producer SDK上传日志到Kafka Cluster

本项目是基于.Net开发的，考虑到日志的灵活性以及使用便利性，决定使用Serilog作为日志组件，开发一个Serilog Sink Kafka，在写本地日志的同时把日志发送到Kafka Cluster，应用只需在启动的时候配置Kafka Sink参数，写日志的时候正常写入即可。

### Serilog介绍

与.NET的许多其他库一样，Serilog也提供对文件，控制台和 其他地方的诊断日志记录 。它易于设置，具有简洁的API，并且可以在最新的.NET平台之间移植。

与其他日志记录库不同，Serilog在构建时考虑了强大的结构化事件数据。

Serilog 消息模板是扩展.NET格式字符串的简单DSL。可以命名参数，并将其值序列化为事件的属性，以实现难以置信的搜索和排序灵活性：

### Serilog.Sink.Kafka

Serilog写日志和接收日志是分离的，有Serilog和Sink两部分，Serilog负责写日志，Sink负责接收日志。同一条日志可以同时被多个接收器消费，社区提供了许多Sink，比如Serilog.Sink.File、Serilog.Sink.Console、Serilog.Sink.Debug等。

现在我们需要自定义一个Serilog.Sink.Kafka接收器，用于把日志发送到Kafka。

自定义Sink需要实现 `ILogEventSink` 接口，这里我使用了 `Serilog.Sinks.PeriodicBatching` 提供的批量异步功能，代码如下

```csharp
    /// <summary>
    /// Serilog Kafka Sink - 允许您使用Serilog将日志发送到Kafka
    /// </summary>
    public class KafkaSink : PeriodicBatchingSink
    {
        private readonly ITextFormatter _formatter;
        private readonly KafkaClient _client;

        public KafkaSink(KafkaClientConfiguration configuration,
            KafkaSinkConfiguration sinkConfiguration) 
            : base(sinkConfiguration.BatchPostingLimit, sinkConfiguration.Period)
        {
            _formatter = sinkConfiguration.TextFormatter;
            _client = new KafkaClient(configuration);
        }

        protected override async Task EmitBatchAsync(IEnumerable<LogEvent> events)
        {
            foreach (var logEvent in events)
            {
                var sw = new StringWriter();
                _formatter.Format(logEvent, sw);
                await _client.PublishAsync(sw.ToString());
            }
        }
    }
```

在重写的 `EmitBatchAsync` 方法中消费日志事件，其中 `ITextFormatter` 是应用启动时配置的文本格式化类型，默认为 `CompactJsonFormatter` 类型，它时紧凑的Json类型，比一般的Json类型体积更小，其中一些具体化的属性如下，[CompactJsonFormatter仓库地址](https://github.com/serilog/serilog-formatting-compact)

| Property | Name | Description |
| -------- | ---- | ----------- |
| `@t`     | Timestamp | An ISO 8601 timestamp |
| `@m`     | Message | A fully-rendered message describing the event |
| `@mt` | Message Template | Alternative to Message; specifies a [message template](http://messagetemplates.org) over the event's properties that provides for rendering into a textual description of the event |
| `@l` | Level | An implementation-specific level identifier (string or number) |
| `@x` | Exception | A language-dependent error representation potentially including backtrace |
| `@i` | Event id | An implementation specific event id (string or number) |
| `@r` | Renderings | If `@mt` includes tokens with programming-language-specific formatting, an array of pre-rendered values for each such token |

核心方法是 `_client.PublishAsync` 方法，代码如下

```csharp
    public async Task PublishAsync(string message)
    {
        using (var p = new ProducerBuilder<Null, string>(_config.ProducerConfig).Build())
        {
            try
            {
                var dr = await p.ProduceAsync(_config.Topic, new Message<Null, string> { Value = message });
            }
            catch (ProduceException<Null, string> e)
            {
                Console.WriteLine($"发送失败: {e.Error.Reason}");
            }
        }
    }
```

这个方法很简单，就是构建一个Kafka生产者对象，然后根据配置的主题发送消息到Kafka，如此一个Serilog.Sink.Kafka就开发完成了。

完整代码将发布到GitHub

## 采集工具上传日志到Kafka Cluster

## Kafka Cluster日志上传到日志服务

## SDK采集日志上传到日志服务