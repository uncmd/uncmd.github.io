---
title: ABP VNext
date: 2020-05-16 23:41:40
tags:
  - ABP
categories:
  - 微服务
---

> ABP是用于创建现代Web应用程序的完整体系结构和强大的基础架构！遵循最佳实践和约定，为您提供SOLID开发经验。

> 官网：https://abp.io/

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/abp-logo-light.svg)

<!-- more -->

## AbpVNext介绍

ABP是一个完整的架构和强大的基础架构，可以创建现代Web应用程序 遵循最佳实践和惯例，为您提供SOLID开发体验。

[官方网址](https://www.abp.io/)

## ABP CLI

### 安装

> ABP CLI (命令行接口) 是一个命令行工具,用来执行基于ABP解决方案的一些常见操作.

ABP CLI 是一个 [dotnet global tool.](https://docs.microsoft.com/en-us/dotnet/core/tools/global-tools) 使用命令行窗口安装:

> dotnet tool install -g Volo.Abp.Cli

更新最新版本：

> dotnet tool update -g Volo.Abp.Cli

### 命令

#### new

生成基于ABP[启动模板](https://docs.abp.io/zh-Hans/abp/latest/Startup-Templates/Index)的新解决方案.

基本用法:

````bash
abp new <解决方案名称> [options]
````

示例:

````bash
abp new Acme.BookStore
````

* Acme.BookStore是解决方案的名称.
* 常见的命名方式类似于 *YourCompany.YourProject*. 不过你可以使用自己喜欢的方式,如 *YourProject* (单级命名空间) 或 *YourCompany.YourProduct.YourModule* (三级命名空间).

##### Options

* `--template` 或 `-t`: 指定模板. 默认的模板是 `mvc`.可用的模板有:
  * `mvc` (默认): ASP.NET Core MVC应用程序模板. 其他选项:
    * `--database-provider` 或 `-d`: 指定数据库提供程序. 默认提供程序是 `ef`. 可用的提供程序有:
      * `ef`: Entity Framework Core.
      * `mongodb`: MongoDB.
    * `--tiered`: 创建分层解决方案,Web和Http Api层在物理上是分开的. 如果未指定会创建一个分层的解决方案, 此解决方案没有那么复杂,适合大多数场景.
  *  `mvc-module`: ASP.NET CoreMVC模块模板]. 其他选项:
    * `--no-ui`: 不包含UI. 仅创建服务模块 (也称为微服务 - 没有UI).
* `--output-folder` 或 `-o`: 指定输出文件夹,默认是当前目录.

#### add-package

添加新的ABP包到项目中

* 添加nuget包做为项目的依赖项目.
* 添加 `[DependsOn(...)]` attribute到项目的模块类 .

> 需要注意的是添加的模块可能需要额外的配置,通常会在包的文档中指出.

基本用法:

````bash
abp add-package <包名> [options]
````

示例:

````
abp add-package Volo.Abp.MongoDB
````

* 示例中将Volo.Abp.MongoDB包添加到项目中.

##### Options

* `--project` 或 `-p`: 指定项目 (.csproj) 路径. 如果未指定,Cli会尝试在当前目录查找.csproj文件.

#### add-module

通过查找模块的所有包,查找解决方案中的相关项目,并将每个包添加到解决方案中的相应项目,从而将多包模块添加到解决方案中.

> 由于分层,不同的数据库提供程序选项或其他原因,业务模块通常由多个包组成. 使用`add-module`命令可以大大简化向模块添加模块的过程. 但是每个模块可能需要一些其他配置,这些配置通常在相关模块的文档中指出.

基本用法:

````bash
abp add-module <模块名称> [options]
````

示例:

```bash
abp add-module Volo.Blogging
```

* 示例中将Volo.Blogging模块添加到解决方案中.

##### Options

* `--solution` 或 `-s`: 指定解决方案 (.sln) 路径. 如果未指定,CLI会尝试在当前目录中寻找.sln文件.
* `--skip-db-migrations`: 对于EF Core 数据库提供程序,它会自动添加新代码的第一次迁移 (`Add-Migration`) 并且在需要时更新数据库 (`Update-Database`). 指定此选项可跳过此操作.

#### update

更新所有ABP相关的包可能会很繁琐,框架和模块都有很多包. 此命令自动将解决方案或项目中所有ABP相关的包更新到最新版本.

用法:

````bash
abp update [options]
````

* 如果你的文件夹中有.sln文件,运行命令会将解决方案中所有项目ABP相关的包更新到最新版本.
* 如果你的文件夹中有.csproj文件,运行命令会将项目中所有ABP相关的包更新到最新版本.

##### Options

* `--include-previews` 或 `-p`: 将预览版, 测试版本 和 rc 包 同时更新到最新版本.

### #help

CLI的基本用法信息.

用法:

````bash
abp help [命令名]
````

示例:

````bash
abp help        # 显示常规帮助.
abp help new    # 显示有关 "New" 命令的帮助.
````

## 远程端点调用

appsettings.json文件包含RemoteServices部分,用于声明远程服务端点. 每个微服务通常都有不同的端点. 使用API网关模式为应用程序提供单个端点:

```json
"RemoteServices": {
  "Default": {
    "BaseUrl": "http://localhost:9000/"
  }
}
```

查找源码，发现 ABP 是通过 DynamicHttpProxyInterceptor 拦截器实现远程端点调用，查看拦截方法如下：

```
public override void Intercept(IAbpMethodInvocation invocation)
{
    if (invocation.Method.ReturnType == typeof(void))
    {
        AsyncHelper.RunSync(() => MakeRequestAsync(invocation));
    }
    else
    {
        var responseAsString = AsyncHelper.RunSync(() => MakeRequestAsync(invocation));

        //TODO: Think on that
        if (TypeHelper.IsPrimitiveExtended(invocation.Method.ReturnType, true))
        {
            invocation.ReturnValue = Convert.ChangeType(responseAsString, invocation.Method.ReturnType);
        }
        else
        {
            invocation.ReturnValue = JsonSerializer.Deserialize(
                invocation.Method.ReturnType,
                responseAsString
            );
        }
    }
}
```

拦截方法主要是调用 MakeRequestAsync 执行远程调用，对于有返回值的方法，如果是基础类型，直接类型转换，否则执行反序列化。

```
private async Task<string> MakeRequestAsync(IAbpMethodInvocation invocation)
{
    var clientConfig = ClientOptions.HttpClientProxies.GetOrDefault(typeof(TService)) ?? throw new AbpException($"Could not get DynamicHttpClientProxyConfig for {typeof(TService).FullName}.");
    var remoteServiceConfig = AbpRemoteServiceOptions.RemoteServices.GetConfigurationOrDefault(clientConfig.RemoteServiceName);

    var client = HttpClientFactory.Create(clientConfig.RemoteServiceName);

    var action = await ApiDescriptionFinder.FindActionAsync(remoteServiceConfig.BaseUrl, typeof(TService), invocation.Method);
    var apiVersion = GetApiVersionInfo(action);
    var url = remoteServiceConfig.BaseUrl.EnsureEndsWith('/') + UrlBuilder.GenerateUrlWithParameters(action, invocation.ArgumentsDictionary, apiVersion);

    var requestMessage = new HttpRequestMessage(action.GetHttpMethod(), url)
    {
        Content = RequestPayloadBuilder.BuildContent(action, invocation.ArgumentsDictionary, JsonSerializer, apiVersion)
    };

    AddHeaders(invocation, action, requestMessage, apiVersion);

    await ClientAuthenticator.Authenticate(
        new RemoteServiceHttpClientAuthenticateContext(
            client,
            requestMessage,
            remoteServiceConfig,
            clientConfig.RemoteServiceName
        )
    );

    var response = await client.SendAsync(requestMessage, GetCancellationToken());

    if (!response.IsSuccessStatusCode)
    {
        await ThrowExceptionForResponseAsync(response);
    }

    return await response.Content.ReadAsStringAsync();
}
```

首先获取客户端代理配置，一般是默认值Default。然后根据客户端代理配置远程服务名称获取远程服务配置，即RemoteServices配置。使用 HttpClientFactory 创建 HttpClient。

action 是远程方法的描述信息，每个ABP服务都有一个api/abp/api-definition接口，以获取服务接口描述信息，这个接口定义在Volo.Abp.AspNetCore.Mvc模块，一般会在*.HttpApi模块中引用。

获取API版本信息，用以构建URL的版本
拼接URL
构建请求信息
添加请求头
身份验证
执行远程请求

拦截器在 ServiceCollectionDynamicHttpClientProxyExtensions 扩展方法中注册，注册方法如下：

```
public static IServiceCollection AddHttpClientProxies(
    [NotNull] this IServiceCollection services,
    [NotNull] Assembly assembly,
    [NotNull] string remoteServiceConfigurationName = RemoteServiceConfigurationDictionary.DefaultName,
    bool asDefaultServices = true)
{
    Check.NotNull(services, nameof(assembly));

    //TODO: Make a configuration option and add remoteServiceName inside it!
    //TODO: Add option to change type filter

    var serviceTypes = assembly.GetTypes().Where(t =>
        t.IsInterface && t.IsPublic && typeof(IRemoteService).IsAssignableFrom(t)
    );

    foreach (var serviceType in serviceTypes)
    {
        services.AddHttpClientProxy(
            serviceType, 
            remoteServiceConfigurationName,
            asDefaultServices
            );
    }

    return services;
}

public static IServiceCollection AddHttpClientProxy(
    [NotNull] this IServiceCollection services,
    [NotNull] Type type,
    [NotNull] string remoteServiceConfigurationName = RemoteServiceConfigurationDictionary.DefaultName,
    bool asDefaultService = true)
{
    Check.NotNull(services, nameof(services));
    Check.NotNull(type, nameof(type));
    Check.NotNullOrWhiteSpace(remoteServiceConfigurationName, nameof(remoteServiceConfigurationName));

    services.Configure<AbpHttpClientOptions>(options =>
    {
        options.HttpClientProxies[type] = new DynamicHttpClientProxyConfig(type, remoteServiceConfigurationName);
    });
    
    //use IHttpClientFactory and polly
    services.AddHttpClient(remoteServiceConfigurationName)
        .AddTransientHttpErrorPolicy(builder =>
            // retry 3 times
            builder.WaitAndRetryAsync(3, i => TimeSpan.FromSeconds(Math.Pow(2, i))));

    var interceptorType = typeof(DynamicHttpProxyInterceptor<>).MakeGenericType(type);
    services.AddTransient(interceptorType);

    var interceptorAdapterType = typeof(CastleAbpInterceptorAdapter<>).MakeGenericType(interceptorType);

    if (asDefaultService)
    {
        services.AddTransient(
            type,
            serviceProvider => ProxyGeneratorInstance
                .CreateInterfaceProxyWithoutTarget(
                    type,
                    (IInterceptor)serviceProvider.GetRequiredService(interceptorAdapterType)
                )
        );
    }

    services.AddTransient(
        typeof(IHttpClientProxy<>).MakeGenericType(type),
        serviceProvider =>
        {
            var service = ProxyGeneratorInstance
                .CreateInterfaceProxyWithoutTarget(
                    type,
                    (IInterceptor) serviceProvider.GetRequiredService(interceptorAdapterType)
                );

            return Activator.CreateInstance(
                typeof(HttpClientProxy<>).MakeGenericType(type),
                service
            );
        });

    return services;
}
```

一般注册整个程序集，实现了IRemoteService接口的服务都会被注册为远程方法。
最佳实践是在*.HttpApi.Client项目中注册*.Application.Contracts程序集，其它微服务只需要依赖*.HttpApi.Client，执行远程端点调用和本地调用一样简单。