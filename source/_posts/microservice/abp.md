---
title: ASP.NET Boilerplate应用与实践
date: 2020-05-16 23:41:40
tags:
  - ABP
categories:
  - 微服务
---

> ASP.NET Boilerplate是一个通用应用程序框架，专门为新的现代Web应用程序设计。它使用已经熟悉的工具并围绕它们实施最佳实践，以为您提供SOLID开发经验。

> 官网：https://aspnetboilerplate.com/

[![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/abp-logo-long.png)](https://uncmd.github.io/microservice/abp/)

<!-- more -->

## 如何获取客户端真实IP，而不是代理IP

自定义实现IClientInfoProvider接口，然后在模块中替换默认的实现

从请求头中获取 X-Forwarded-For 信息，代理会把每层的请求信息存到 X-Forwarded-For 中，包括客户端信息

```
    public class HttpContextClientInfoProxyProvider : HttpContextClientInfoProvider, ITransientDependency
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        private readonly HttpContext _httpContext;

        public HttpContextClientInfoProxyProvider(IHttpContextAccessor httpContextAccessor)
            : base(httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
            _httpContext = httpContextAccessor.HttpContext;
        }

        protected override string GetClientIpAddress()
        {
            try
            {
                var httpContext = _httpContextAccessor.HttpContext ?? _httpContext;

                var headers = httpContext?.Request.Headers;
                if (headers != null && headers.ContainsKey("X-Forwarded-For"))
                {
                    httpContext.Connection.RemoteIpAddress = System.Net.IPAddress.Parse(headers["X-Forwarded-For"].ToString().Split(',', StringSplitOptions.RemoveEmptyEntries)[0]);
                }

                return httpContext?.Connection?.RemoteIpAddress?.ToString();
            }
            catch (Exception ex)
            {
                Logger.Warn(ex.ToString());
            }

            return null;
        }
    }
```

在Web.Core模块的预加载事件PreInitialize中替换默认实现：

```
 Configuration.ReplaceService<IClientInfoProvider, HttpContextClientInfoProxyProvider>(DependencyLifeStyle.Transient);
```

> 特别注意：Ocelot网关默认不会存 X-Forwarded-For信息，需要在网关配置文件添加如下配置：

```json
    "UpstreamHeaderTransform": {
    "X-Forwarded-For": "{RemoteIpAddress}"
    }
```

这样审计日记获取的客户端IP地址才是真实的。


## 审计日志添加自定义数据（服务端地址）

自己实现IAuditInfoProvider接口，可以继承默认的实现，然后重写Fill方法

```
    public class QmsAuditInfoProvider : DefaultAuditInfoProvider, ITransientDependency
    {
        private readonly IConfigurationRoot _appConfiguration;

        public QmsAuditInfoProvider(IConfigurationRoot configurationRoot)
        {
            _appConfiguration = configurationRoot;
        }

        public override void Fill(AuditInfo auditInfo)
        {
            base.Fill(auditInfo);

            auditInfo.CustomData = $"服务地址：{_appConfiguration["App:ServerRootAddress"]}";
        }
    }
```
	
这里注入了配置文件，从配置文件读取服务地址，然后保存到审计日志的CustomData字段

然后在Web.Host模块的PreInitialize方法中替换IAuditInfoProvider接口的默认实现

```
Configuration.ReplaceService(typeof(Abp.Auditing.IAuditInfoProvider), () =>
{
    IocManager.Register<IAuditInfoProvider, AssemblyReportAuditInfoProvider>(DependencyLifeStyle.Transient);
});
```


## 动态C# API客户端

参考Abp vnext 提供动态 C# API客户端功能

可以自动创建C# API 客户端代理来调用远程HTTP服务(REST APIS).通过这种方式,你不需要通过 HttpClient 或者其他低级的HTTP功能调用远程服务并获取数据.

### 服务接口

你的service或controller需要实现一个在服务端和客户端共享的接口.因此,首先需要在一个共享的类库项目中定义一个服务接口.例如:

```
public interface IBookAppService : IApplicationService
{
    Task<List<BookDto>> GetListAsync();
}
```

为了能自动被发现,你的接口需要实现IApplicationService接口.

### 服务元数据接口

客户端调用服务时，需要知道服务接口的元数据，Core.Http通过AbpApiDefinitionController控制器发布服务元数据，如下：

```
[Route("api/abp/api-definition")]
public class AbpApiDefinitionController : AbpController, IRemoteService
{
    private readonly IApiDescriptionModelProvider _modelProvider;

    public AbpApiDefinitionController(IApiDescriptionModelProvider modelProvider)
    {
        _modelProvider = modelProvider;
    }

    [HttpGet]
    public ApplicationApiDescriptionModel Get()
    {
        return _modelProvider.CreateApiModel();
    }
}
```

路由地址为 api/abp/api-definition，通过这个接口访问各个微服务的接口元数据

在 Web.Core项目中添加 AbpHttpModule 依赖，自动注册 AbpApiDefinitionController 控制器

```
[DependsOn(typeof(AbpHttpModule))] //添加依赖
public class MyWebCoreModule : AbpModule
{
}
```

### 客户端代理生成

首先将 Core.Http.Client 添加到客户端项目中

然后给你的模块添加 AbpHttpClientModule 依赖

```
[DependsOn(typeof(AbpHttpClientModule))] //添加依赖
public class MyClientAppModule : AbpModule
{
}
```

现在，已经可以创建客户端代理了，例如：

```
[DependsOn(
    typeof(AbpHttpClientModule), //用来创建客户端代理
    typeof(BookStoreApplicationModule) //包含应用服务接口
    )]
public class MyClientAppModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        var service = IocManager.Resolve<IServiceCollection>();

        //创建动态客户端代理
        service.AddHttpClientProxies(typeof(BookStoreApplicationModule).Assembly, RemoteServiceName);
    }
}

```

AddHttpClientproxies方法获得一个程序集,找到这个程序集中所有的服务接口,创建并注册代理类.

注意：需要在 Starup 中注册 IServiceCollection，如：

```
// Configure Abp and Dependency Injection
return services.AddAbp<QMSWebHostModule>(
    // Configure Log4Net logging
    options =>
    {
        options.IocManager.IocContainer.AddFacility<LoggingFacility>(
            f => f.UseAbpLog4Net().WithConfig("log4net.config")
        );

        options.IocManager.Register(typeof(IServiceCollection), services.GetType());
    }
);
```

#### Endpoint配置

appsettings.json文件中的RemoteServices节点被用来设置默认的服务地址.下面是最简单的配置:

```json
{
  "RemoteServices": {
    "Default": {
      "BaseUrl": "http://localhost:53929/"
    } 
  } 
}
```

### 使用

可以很直接地使用.只需要在你的客户端程序中注入服务接口:

```
public class MyService : ITransientDependency
{
    private readonly IBookAppService _bookService;

    public MyService(IBookAppService bookService)
    {
        _bookService = bookService;
    }

    public async Task DoIt()
    {
        var books = await _bookService.GetListAsync();
        foreach (var book in books)
        {
            Console.WriteLine($"[BOOK {book.Id}] Name={book.Name}");
        }
    }
}

```

本例注入了上面定义的IBookAppService服务接口.当客户端调用服务方法的时候动态客户端代理就会创建一个HTTP调用.

### 配置

#### RemoteServiceOptions

默认情况下RemoteServiceOptions从appsettings.json获取.或者,你可以使用Configure方法来设置或重写它.如:

```
public override void Initialize()
{
    AbpConfigurationExtensions.ConfigureOptions<AbpRemoteServiceOptions>(option =>
    {
        option.RemoteServices.Default = new RemoteServiceConfiguration("/");
    });
}

```

#### 多个远程服务端点

上面的例子已经配置了"Default"远程服务端点.你可能需要为不同的服务创建不同的端点.(就像在微服务方法中一样,每个微服务具有不同的端点).在这种情况下,你可以在你的配置文件中添加其他的端点:

```json
{
  "RemoteServices": {
    "Default": {
      "BaseUrl": "http://localhost:53929/"
    },
    "BookStore": {
      "BaseUrl": "http://localhost:48392/"
    } 
  } 
}
```

AddHttpClientProxies方法有一个可选的参数来定义远程服务的名字:

```
context.Services.AddHttpClientProxies(
    typeof(BookStoreApplicationModule).Assembly,
    remoteServiceName: "BookStore"
);
```

remoteServiceName参数会匹配通过RemoteServiceOptions配置的服务端点.如果BookStore端点没有定义就会使用默认的Default端点.

