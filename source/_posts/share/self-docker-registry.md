---
title: Linux 部署 .NET Core（搭建私有镜像仓库）
date: 2020-06-8 15:57:40
tags:
  - Linux
  - .NET Core
  - Docker
categories:
  - 分享
---

> 前面我们是把dll发布到服务器，然后在服务器把dll打包成镜像，更通用的做法是在本地打包成镜像然后推送到镜像仓库，服务器拉取最新镜像运行容器。镜像仓库可以是Docker官方的公共镜像仓库[Docker Hub](https://hub.docker.com/)，为了避免暴露也可以自建私有镜像仓库。下面简单介绍自建私有镜像仓库及其发布部署流程。

**运行环境**

* 腾讯云

* CentOS 7.5 64位

* 1核 2GB内存 1M带宽

<!-- more -->

## Registry私有镜像仓库

[Docker Hub](https://hub.docker.com/)是 Docker 默认的官方镜像仓库，包含许多镜像。如果想要搭建私有镜像仓库， Docker 提供了 Registry 镜像，使得搭建私有仓库非常简单。

### 搭建镜像仓库

1. 先在服务器中下周 Registry 镜像

```bash
docker pull registry
```

2. 运行一个 Registry 镜像仓库的容器实例

```bash
docker run -d -v /edc/images/registry:/var/lib/registry -p 6000:5000 --restart=always --name uncmd-registry registry
```

3. 查看镜像

```bash
curl http://your-server-ip:6000/v2/_catalog
```

4. 上传镜像

> 要上传镜像到私有仓库，需要在镜像的 tag 上加入仓库地址

```bash
docker tag your-image-name:tagname your-server-ip:6000/your-image-name:tagname
```

> 注意仓库地址没有加协议部分，docker 默认的安全策略需要仓库是支持 https 的，如果服务器只能使用 http 传输，那么直接上传会失败，需要在 docker 客户端的配置文件中进行声明，增加 `insecure-registries` 配置。

```bash
vim /etc/docker/daemon.json
{
    "registry-mirrors": ["https://registry.docker-cn.com"],
    "insecure-registries": ["150.158.107.66:6000"],
    "live-restore": true
}
```

重新启动 docker 服务使配置生效

```bash
systemctl restart docker
```

> 开始上传镜像到服务端镜像仓库

```bash
docker push your-registry-server-ip:6000/your-image-name:tagname
```

5. 下载镜像

直接使用 `pull` 命令下载镜像即可

```bash
docker pull your-server-ip:6000/your-image-name:tagname
```

可以通过下面的api获取要下载的镜像有哪些tag（版本）

```bash
curl http://your-server-ip:6000/v2/your-image-name/tags/list
```