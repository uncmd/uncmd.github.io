---
title: Linux 部署 .NET Core（普通部署）
date: 2020-05-30 16:24:40
tags:
  - Linux
  - .NET Core
categories:
  - 分享
---

> 在腾讯云 CentOS 部署运行 .Net core 应用

**运行环境**

* 腾讯云

* CentOS 7.5 64位

* 1核 2GB内存 1M带宽

* 辅助工具 xftp

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/linux-netcore-face.jpg)

<!-- more -->

## 安装 dotnet sdk

* 安装 `libicu` 依赖

```bash
yum install libunwind libicu
```

* 注册dotnet 的repository

```bash
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
```

* 安装SDK

```bash
sudo yum update
sudo yum install dotnet-sdk-3.1
```

* 以下命令用来模糊查询dotnet-sdk可用版本，`\*` 表示适配不定长的所有字符

```bash
yum list dotnet-sdk\*
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/yum-list-dotnet-sdk-search.jpg)_`yum list dotnet-sdk\*`_

* 查看安装信息

```bash
dotnet --info
```

## 上传应用程序到Linux

### CentOS搭建FTP服务

* 安装 vsftpd

```bash
yum install vsftpd // 安装
vsftpd -v          // 查看安装版本
```

* 启动 vsftpd

```bash
systemctl start vsftpd.service   // 启动
systemctl restart vsftpd.service // 重启
systemctl enable vsftpd.service  //设置开机自启动
systemctl status vsftpd.service  // 查看服务状态
netstat -nltp | grep 21          // 查看服务端口
tail -f /var/log/secure          // 查看安全日志
```

* 配置文件说明

```bash
/etc/vsftpd/vsftpd.conf 是 vsftpd 的核心配置文件。
/etc/vsftpd/ftpusers    是黑名单文件，此文件里的用户不允许访问 FTP 服务器。
/etc/vsftpd/user_list   是白名单文件，此文件里的用户允许访问 FTP 服务器。
```

在 ESC 安全策略的入站规则添加 21 端口，允许访问 21 端口

### 配置 vsftpd

vsftpd 安装后默认开启了匿名访问 FTP 服务器的功能，使用匿名用户访问，无需输入用户名和密码即可登录 FTP 服务，但是没有权限修改或上传文件。

此处我配置**本地用户登录**

本地用户登录是指用户使用 Linux 操作系统的账号和密码登录 FTP 服务器。

1、创建一个账号 ftptest 并设置一个密码

```bash
useradd ftptest            // 创建用户
passwd --stdin ftptest     // 设置密码
cut -d : -f 1 /etc/passwd  // 查看系统用户
userdel -r username        // 删除用户
```

2、创建一个供FTP服务使用的文件目录

```bash
mkdir /var/ftp/test
```

3、更改 /var/ftp/test 目录的拥有者为 ftptest

```bash
chown ftptest:ftptest /var/ftp/test -R
```

4、修改配置文件前先进行备份一下

```bash
cp /etc/vsftpd/vsftpd.conf{,.bak}
```

5、修改 vsftpd.conf 配置文件

```config
#禁止匿名登录FTP服务器
anonymous_enable=NO
#允许本地用户登录FTP服务器
local_enable=YES
#设置本地用户登录后所在目录
local_root=/var/ftp/test#全部用户被限制在主目录
chroot_local_user=YES#开启被动模式
pasv_enable=YES
#FTP服务器公网IP（也就是当前腾讯云服务器的公网 IP）
pasv_address=120.xx.xx.xx
#设置被动模式下，建立数据传输可使用port范围的最小值
pasv_min_port=10000
#设置被动模式下，建立数据传输可使用port范围的最大值
pasv_max_port=10088

#本地用户上传文件的umask
local_umask=022
#是否在进入新目录时显示 message_file 文件中的内容
dirmessage_enable=YES
#启用日志
xferlog_enable=YES
#日志是否进行格式化
xferlog_std_format=YES
#独立服务   
listen=YES
#centos7增加此设置，开启后默认监控ipv4和ipv6
listen_ipv6=NO
#认证模式 
pam_service_name=vsftpd
#启用用户列表 
userlist_enable=YES
#可以上传(全局控制)   
write_enable=YES
#允许下载  
download_enable=YES
```

6、 重新启动 vsftpd

```bash
systemctl restart vsftpd.service
```

在本地使用 xftp 上传工具，上传目录是 /home/uncmd/gateways/InternalGateway

查看目录文件，上传成功

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/ftp-upload.jpg)

### 准备你的.net core web 程序

新建一个空的.net core web程序用以演示

首先确保你的项目能在windows上运行

接下来发布

* 先发布到本地目录，然后使用 xftp 工具上传到云服务器

* 直接使用 Vistual Studio 发布到FTP

我选择的是直接发布到FTP，配置如下

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/dotnet-publish-ftp.jpg)

验证连接没问题后点击发布，将文件发布到FTP对应目录

到程序所在目录执行以下命令启动web站点

```bash
dotnet InternalGateway.dll
```

显示正在运行，现在打开 http://你的服务器ip:5000

> http://地址:5000无法访问

云服务器入站规则已正确设置，查看端口监听情况

```
netstat -anpt | grep 5000
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/share/show-port-listen.jpg)

* 从上图能够看出用户的web服务被绑定在127.0.0.1的5000端口上了，而这会导致公网无法访问该web服务，解释如下：

    - 127.0.0.1是一个回送（loopback）地址，指本地机，一般用来测试使用

    - 127.0.0.1是通过网卡传输，依赖网卡，并受到网络防火墙和网卡相关的限制,这也是跟localhost重要区别之一，localhost是不走网卡的，因此防火墙设置对localhost是无效的。

    - 正常的网络包都是从ip层进入链路层，然后发送到网络上，而发向127.0.0.1的包，直接在IP层短路了，也就是发到IP层的包直接被IP层接收了，不再向下发送。这也就决定了web应用绑定在127.0.0.1上是不可能被公网访问到的。

* 解决方案：

    - 修改web容器配置，把web应用绑定在ecs主网卡上。ECS bind EIP，实际上相当于EIP与ECS私有主网卡建立了映射关系，因此通过EIP:5000来访问web服务，最终就会*请求到私网主网卡:5000上。

    - 更好的做法是把web服务绑定在0.0.0.0这个特殊IP上，关于0.0.0.0，这个IP并不是真实存在的，我们ping不通它，它只是一个符号，代表当前设备的IP。绑定在0.0.0.0上后无论是通过127.0.0.1还是本机ip去访问web服务，都是可以的。

    - 在 appsettings.json 配置文件中添加 `"urls": "http://0.0.0.0:5000"` 配置

配置正确后打开 http://你的服务器ip:5000 可正常访问

### 守护进程

* 安装

```bash
yum install python-setuptools
easy_install supervisor
```

* 配置

```bash
mkdir /etc/supervisor
echo_supervisord_conf > /etc/supervisor/supervisord.conf
```

在 /etc/supervisor/supervisord.conf 最后加上如下两行

```config
[include]
files = conf.d/*.conf
```

创建 /etc/supervisor/conf.d 目录，用于存放配置

* 添加对 InternalGateway.dll 的守护

添加 /etc/supervisor/conf.d/InternalGateway.conf 文件，内容如下

```config
[program:InternalGateway]
command=dotnet InternalGateway.dll ; 运行程序的命令
directory=/home/wwwroot/InternalGateway/ ; 命令执行的目录
autorestart=true ; 程序意外退出是否自动重启
stderr_logfile=/var/log/InternalGateway.err.log ; 错误日志文件
stdout_logfile=/var/log/InternalGateway.out.log ; 输出日志文件
environment=ASPNETCORE_ENVIRONMENT=Production ; 进程环境变量
user=root ; 进程执行的用户身份
stopsignal=INT
```

* 运行 supervisord，查看是否生效

```bash
supervisord -c /etc/supervisor/supervisord.conf
ps -ef | grep InternalGateway
```

* Supervisor配置开机启动

```bash
cd /usr/lib/systemd/system/
vim supervisord.service
```

插入以下内容

```config
# dservice for systemd (CentOS 7.0+)
# by ET-CS (https://github.com/ET-CS)
[Unit]
Description=Supervisor daemon
[Service]
Type=forking
ExecStart=/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
ExecStop=/usr/bin/supervisorctl shutdown
ExecReload=/usr/bin/supervisorctl reload
KillMode=process
Restart=on-failure
RestartSec=42s
[Install]
WantedBy=multi-user.target
```

激活开机启动

```bash
systemctl enable supervisord
```

查看是否已激活

```bash
systemctl is-enabled supervisord
```

* supervisor 服务常用命令

```bash
supervisorctl status        //查看所有进程的状态
supervisorctl stop es       //停止es
supervisorctl start es      //启动es
supervisorctl restart       //重启es
supervisorctl update        //配置文件修改后使用该命令加载新的配置
supervisorctl reload        //重新启动配置中的所有程序
```

### CentOS下使用命令行Web浏览器Links

Links是一个运行在命令行模式下的Web浏览器，只能查看字符

安装Links

```bash
yum install links
```

使用Links

links URL

Esc键：调出Links顶部菜单。

方向键：选择不同的项目，展示下拉菜单或者翻页。

Q键（大写Q）：退出Links