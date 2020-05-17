---
title: Hexo博客搭建
date: 2020-05-17 23:41:40
tags:
  - 分享
  - Hexo
categories:
  - 笔记
---

一年前搭建的[个人博客](https://uncmd.github.io/doc-st/#!index.md)被说太~~难看~~简单，最近正好看到Hexo这款快速、简洁且高效的博客框架，故折腾之

* [Hexo](https://hexo.io/zh-cn/)

* [主题Yun](https://github.com/YunYouJun/hexo-theme-yun)

<!-- more -->

旧博客是采用[MDWIKI](https://github.com/Dynalon/mdwiki/)搭建的，有兴趣的同学可以参考使用🙄

## Hexo

Hexo的文档很全，网上教程也很多，跟着文档步骤执行即可，我说下我搭建的大致步骤

### Node

下载[Node.js](https://nodejs.org/zh-cn/)(Node.js 版本需不低于 8.10，建议使用 Node.js 10.0 及以上版本)

下载的是长期支持版，全部默认下一步进行安装

输入 `node --version` 查看安装的Node版本

切换为 `taobao` 镜像源

```bash
npm config set registry https://registry.npm.taobao.org
```

### Git

下载[Git](https://git-scm.com/)

全部默认下一步进行安装，默认编辑器推荐选择[VS Code](https://code.visualstudio.com/)

如果尚未注册[GitHub](https://github.com/)，还需提前注册GitHub账号，利用 [GitHub Pages](https://pages.github.com/) 这一服务部署静态站点

在 GitHub 新建仓库，仓库名称必须为 `你的用户名.github.io` 

### 安装 Hexo

在终端输入以下命令

```bash
npm install hexo-cli -g
```

> [npm](https://www.npmjs.cn/) 是随Node.js一起被安装的包管理器

> install 表示安装

> `hexo-cli` 是 `hexo` 的命令行工具，可以生成模板文件和启动站点等操作

> `-g` 表示全局安装，可以在任何目录下使用，如果不加 `-g` 参数则只能在安装的目录下使用hexo命令行工具

新建一个目录存放Hexo代码，然后在这个目录下面执行以下命令初始化站点

```bash
hexo init 你的名字.github.io
```

安装所有 `package.json` 文件中的包

```bash
npm install
```

启动本地的Hexo服务器

```bash
hexo server
```

这时就可以打开浏览器，在地址栏中输入 http://localhost:4000 查看本地网页了。

在终端中按 `Ctrl + C` 中断服务器的运行

> 更多信息请参考 [Hexo](https://hexo.io/zh-cn/docs/) 官网文档

## 主题

Hexo 默认提供的是 [hexo-theme-landscape](https://github.com/hexojs/hexo-theme-landscape) 主题。

默认主题样式简单，功能较少。在[Themes | Hexo](https://hexo.io/themes/)上有许多有趣美丽的主题。

最终我找了一款样式精美、轻量、快速的主题 [hexo-theme-yun](https://github.com/YunYouJun/hexo-theme-yun)

### 下载 Hexo 主题

使用终端进入之前Hexo初始化好的文件夹目录下，输入以下命令克隆主题

```bash
git clone https://github.com/YunYouJun/hexo-theme-yun themes/yun
```

### 编辑 Hexo 配置

修改Hexo目录下面 `_config.yml` 配置文件的 `theme` 字段，将 `landscape` 改为 `yun`

```bash
theme: yun
```

安装渲染器

```bash
npm install hexo-render-pug hexo-renderer-stylus
```

这时用 `hexo server` 重新启动服务器，就可以看到不一样的主题风格页面了。

### 自定义主题配置

主题配置文件放在 `themes/yun/_config.yml` 文件中，但是最好不要直接修改这个配置文件，以后主题升级会覆盖这个文件

解决方案是在博客的根目录下新建 `source/_data/yun.yml` 自定义配置文件

`themes-yun`会将自定义配置与默认配置进行合并，因此你只需要在 `yun.yml` 文件中自定义你需要的配置即可，其余仍将自动采用默认配置。

