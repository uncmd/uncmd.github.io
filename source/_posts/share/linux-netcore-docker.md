---
title: Linux 部署 .NET Core（容器部署）
date: 2020-05-31 9:24:40
tags:
  - Linux
  - .NET Core
  - Docker
categories:
  - 分享
---

> 在腾讯云 CentOS 部署运行 .Net core 应用

**运行环境**

* 腾讯云

* CentOS 7.5 64位

* 1核 2GB内存 1M带宽

* docker：19.03.10

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/linux-netcore-docker-face.jpg)

<!-- more -->

## 安装 Docker

* Docker 软件包已经包括在默认的 CentOS-Extras 软件源里，所以只需运行下面的yum命令

```bash
yum install docker
```

* 安装完成后，使用下面的命令来启动 docker 服务，并将其设置为开机启动

```bash
systemctl start docker.service
systemctl enable docker.service
```

* 测试

```bash
docker version
```

返回如下版本信息，说明 docker 安装成功

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/docker-version.jpg)_`docker version`_

* 使用中国官方镜像加速，修改 docker 配置文件为

```
vi  /etc/docker/daemon.json
{
    "registry-mirrors": ["https://registry.docker-cn.com"],
    "live-restore": true
}
```

* 运行 Hello World

```bash
docker pull library/hello-world # 拉取hello-world镜像

docker images # 查看本地镜像
# 显示结果
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
docker.io/hello-world   latest              bf756fb1ae65        4 months ago        13.3 kB

docker run hello-world # 运行 hello-world 镜像
# 显示结果
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

## 卸载 Docker

1、查询安装过的包

```bash
yum list installed | grep docker
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/docker-uninstall-showinstalled.jpg)

2、删除安装的软件包

```bash
yum -y remove containerd.io.x86_64 // 依赖删除 docker-ce.x86_64
yum -y remove docker-ce-cli.x86_64
```

3、删除镜像容器等

```bash
rm -rf /var/lib/docker
```

## Dockerfile 使用介绍

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/DockerFile.png)_Docker 镜像、容器和 Dockerfile 三者之间的关系_

通过上图可以看出使用 Dockerfile 定义镜像，运行镜像启动容器。

### Dockerfile 概念

Docker 镜像是一个特殊的文件系统，除了提供容器运行时所需的程序、库、资源、配置等文件外，还包含了一些为运行时准备的一些配置参数（如匿名卷、环境变量、用户等）。镜像不包含任何动态数据，其内容在构建之后也不会被改变。

镜像的定制实际上就是定制每一层所添加的配置、文件。如果我们可以把每一层修改、安装、构建、操作的命令都写入一个脚本，用这个脚本来构建、定制镜像，那么之前提及的无法重复的问题、镜像构建透明性的问题、体积的问题就都会解决。这个脚本就是 Dockerfile。

Dockerfile 是一个文本文件，其内包含了一条条的指令(Instruction)，每一条指令构建一层，因此每一条指令的内容，就是描述该层应当如何构建。有了 Dockerfile，当我们需要定制自己额外的需求时，只需在 Dockerfile 上添加或者修改指令，重新生成 image 即可，省去了敲命令的麻烦。

### Dockerfile 文件格式

Dockerfile 文件格式如下

```bash
##  Dockerfile文件格式

# 1、指定基于哪个基础镜像，必须作为第一个命令！
# 格式：FROM <image> 或者  FROM <image>:<tag>
FROM microsoft/dotnet:3.1-aspnetcore-runtime
 
# 2、维护者信息
# 格式：  MAINTAIN <name> 
MAINTAINER docker_user docker_user@email.com

# 3、镜像操作指令！
# 格式：RUN <command>  或者 RUN [“executable”, “param1”, “param2”]
RUN  yum install httpd
RUN ["/bin/bash", "-c", "echo hello"]

# 4. 构建容器后调用，容器启动后才能调用！
# 三种格式：CMD ["executable", "param1", "param2"]、CMD command param1 param2、CMD ["param1", "param2"]
# RUN和CMD看起来挺像，但是CMD用来指定容器启动时用到的命令，只能有一条。
CMD ["/bin/bash", "/usr/local/nginx/sbin/nginx", "-c", "/usr/local/nginx/conf/nginx.conf"]

# 5. EXPOSE：指定于外界交互的端口！
# 格式： EXPOSE <port> [<port>...] 
EXPOSE 22 80 8443 # 这个用来指定要映射出去的端口，比如容器内部我们启动了sshd和nginx，所以我们需要把22和80端口暴漏出去。
# 这个需要配合-P（大写）来工作，也就是说在启动容器时，需要加上-P，让它自动分配。如果想指定具体的端口，也可以使用-p（小写）来指定。

# 6. ENV：设置环境变量！
# 格式： ENV  <key> <value>
ENV PATH /usr/local/mysql/bin:$PATH # 它主要是为后续的RUN指令提供一个环境变量，我们也可以定义一些自定义的变量
ENV ASPNETCORE_ENVIRONMENT "Development"

# 7. ADD： 将本地文件添加到容器中，tar类型文件会自动解压(网络压缩资源不会被解压)，可以访问网络资源，类似wget！
# 格式： add <src> <dest>将本地的一个文件或目录拷贝到容器的某个目录里。 其中src为Dockerfile所在目录的相对路径，它也可以是一个url。
ADD <conf/vhosts> </usr/local/nginx/conf>

# 8. COPY：功能类似ADD，但是不能自动解压文件，也不能访问网络资源！
# 格式：和ADD一样，不同的是，它不支持url
COPY ..

# 9. ENTRYPOINT：配置容器，使其可执行化。配合CMD可省去"application"，只使用参数！
# 格式：类似CMD
# 容器启动时要执行的命令，它和CMD很像，也是只有一条生效，如果写多个只有最后一条有效。
# CMD不同是：CMD 是可以被 docker run 指令覆盖的，而ENTRYPOINT不能覆盖。比如，容器名字为xiaoming
# 我们在Dockerfile中指定如下CMD：
# CMD ["/bin/echo", "test"]
# 启动容器的命令是  docker run xiaoming 这样会输出 test
# 假如启动容器的命令是 docker run -it xiaoming  /bin/bash  什么都不会输出
# ENTRYPOINT不会被覆盖，而且会比CMD或者docker run指定的命令要靠前执行
# ENTRYPOINT ["echo", "test"]
# docker run -it xiaoming  123
# 则会输出 test  123 ，这相当于要执行命令  echo test  123 
ENTRYPOINT ["dotnet", "InternalGateway.dll"]

# 10. VOLUME：用于持久化目录！
# 格式： VOLUME ["/data"]
# 创建一个可以从本地主机或其他容器挂载的挂载点。

# 11. USER：指定容器运行用户，一般不指定默认ROOT用户！
# 格式：USER daemon
USER username
 
# 12. WORKDIR：  工作目录，类似CD命令！
# 格式： WORKDIR  /path/to/workdir
# 为后续的RUN、CMD或者ENTRYPOINT指定工作目录
WORKDIR /app

# 13. LABEL 为镜像添加元数据，以键值对的形式指定
# 格式：LABEL <key>=<value> <key>=<value> <key>=<value> ...
# 使用LABEL指定元数据时，一条LABEL指定可以指定一或多条元数据，指定多条元数据时不同元数据之间通过空格分隔。
# 推荐将所有的元数据通过一条LABEL指令指定，以免生成过多的中间镜像。
LABEL version="1.0" description="这是一个Web服务器" by="IT笔录"

# 14. ARG 指定传递给构建运行时的变量
# 语法：ARG <name>[=<default value>]
# 在使用 docker build 构建镜像时，可以通过 --build-arg <varname>=<value> 参数来指定或重设置这些变量的值
ARG build_user=IT笔录
LABEL user=$build_user

# 15. ONBUILD 设置镜像触发器
# 语法：ONBUILD [INSTRUCTION]
ONBUILD ADD . /app/src
ONBUILD RUN /usr/local/bin/python-build --dir /app/src

# 16. SHELL 设置执行命令所使用的默认shell类型
# 语法：SHELL ["executable", "parameters"]
# 常用于 Windows 环境
SHELL ["powershell", "-command"]
```

Dockerfile 分为四部分：**基础镜像信息、维护者信息、镜像操作指令、容器启动执行指令**。一开始必须要指明所基于的镜像名称，接下来一般会说明维护者信息；后面则是镜像操作指令，例如 RUN 指令。每执行一条RUN 指令，镜像添加新的一层，并提交；最后是 CMD 指令，来指明运行容器时的操作命令。

### 构建镜像

docker build 命令会根据 Dockerfile 文件及上下文构建新 Docker 镜像

```bash
docker build .
docker build -t nginx/v3 . # 镜像标签
docker build -t nginx/v3:1.0.2 -t nginx/v3:latest .  # 可以使用多个镜像标签
```

### 简单示例

定制 nginx 镜像，在空白目录新建Dockerfile文件

```bash
mkdir mynginx
cd mynginx
vi Dockerfile
```

Dockerfile文件内容为

```bash
FROM nginx
RUN echo '<h1>Hello, Docker!</h1>' > /usr/share/nginx/html/index.html
```

FROM 指定基础镜像为 nginx，RUN 重写了 nginx 的默认页面信息

在 Dockerfile 文件所在目录执行

```bash
docker build -t nginx:v1 . # 最后的 . 表示当前目录
```

用 `docker run` 命令启动容器

```bash
docker run --name docker_nginx_v1 -d -p 80:80 nginx:v1
```

这条命令会用 nginx 镜像启动一个容器，命名为 `docker_nginx_v1`，并且映射了 80 端口，这样我们可以用浏览器去访问这个 nginx 服务器：http://localhost，页面返回：Hello, Docker!

## 准备 .net core web 程序

使用上一节的 .net core web 程序，在根目录添加 Dockerfile 文件，内容如下

```bash
FROM mcr.microsoft.com/dotnet/core/runtime:3.1-buster-slim
WORKDIR /app
COPY . . # 注意中间有个空格
ENTRYPOINT ["dotnet", "InternalGateway.dll"]
```

设置 Dockerfile 文件的属性始终复制到输出目录

发布上传到 Linux

构建镜像，Dockerfile所在的文件夹执行

```bash
docker build -t uncmd/internalgateway .
```

长时间的等待，构建成功，使用 `docker images` 查看

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/docker-images.jpg)_`docker images`_

启动刚才构建好的容器

```bash
docker run --name internalgateway -p 5000:80 uncmd/internalgateway
docker ps # 查看运行中的容器
```

**容器设置自动启动，启动时加 --restart=always参数**

```bash
docker run --name internalgateway -p 5000:80 --restart=always uncmd/internalgateway
```
* no             不自动重启容器（默认值）

* on-failure     容器发生错误而退出（容器退出状态不为0）重启容器

* unless-stopped 在容器已经stop掉或docker stoped/restarted的时候才重启容器

* always 	     在容器已经stop掉或Docker stoped/restarted的时候才重启容器

容器运行正常，浏览器访问 http://服务器IP:5000

> 第一次部署过程踩了较多坑，记录在此

> `docker build` 构建的镜像名称和标签为 non

原因使镜像构建不成功，仔细查看构建输出日志，在哪一步失败，然后根据提示修改 Dockerfile 文件直至成功

> `docker run` 映射的端口为空，`docker ps -a` 查看端口没有映射，并且 `docker start` 启动不了容器

原因是容器运行时错误，但是 `-d` 参数隐藏了具体错误，对于不了解的同学很容易被误导

* 使用 `docker rm` 命令删除容器

* `docker run` 命令去掉 `-d` 参数，使运行错误在前台展示

* 根据错误修改 Dockerfile 文件，重新生成镜像并运行

页面正常访问，至此，.net core 程序 docker 部署方式完成。

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/docker-result.jpg)_访问5000端口_

## Docker 常用命令

```bash
docker pull image_name # 拉取docker镜像

docker images # 查看宿主机上的镜像，Docker镜像保存在/var/lib/docker目录下

docker rmi docker.io/hello-world 或 docker rmi bf756fb1ae65 # 删除镜像

docker ps # 查看当前有哪些容器正在运行

docker ps -a # 查看所有容器

docker start container_name/container_id # 启动容器

docker stop container_name/container_id # 停止容器

docker restart container_name/container_id # 重启容器

docker attach container_name/container_id # 后台启动一个容器后，如果想进入到这个容器，可以使用attach命令

docker rm container_id # 删除容器

docker info # 查看当前系统Docker信息

docker pull centos:latest # 将Centos这个仓库下面的所有镜像下载到本地repository

docker image prune # 清理镜像
```

> **参考**

> https://www.cnblogs.com/ityouknow/p/8520296.html

> https://www.cnblogs.com/xiaxiaolu/p/9973631.html