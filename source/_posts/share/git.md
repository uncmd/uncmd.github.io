---
title: git使用技巧
date: 2020-05-20 19:56:40
tags:
  - git
categories:
  - 分享
---

> Git（读音为/gɪt/）是一个开源的分布式版本控制系统，可以有效、高速地处理从很小到非常大的项目版本管理。

> 官网地址：https://git-scm.com/

[![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git.jpg)](https://uncmd.github.io/share/git/)

<!-- more -->

## 一个有趣的开源项目，藏着git快速入门的秘密

开源地址：

https://github.com/pcottle/learnGitBranching

游戏地址：

https://learngitbranching.js.org/?demo

LearnGitBranching是一个git仓库可视化工具，沙箱以及一系列教育性教程和挑战。其主要目的是帮助开发人员通过可视化功能（在命令行上工作时缺少的功能）来理解git。这是通过具有不同级别的游戏来熟悉不同的git命令来实现的。

您可以在LearnGitBranching（LGB）中输入各种命令-处理命令时，附近的提交树将动态更新以反映每个命令的效果：

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git.gif)_LearnGitBranching 游戏演示_

## 本地仓库

### 基础篇

#### git commit

用 `git commit` 来创建新的提交记录

#### git branch

> 早建分支，多用分支

用 `git branch <分支名>` 来创建分支，用 `git checkout <分支名>` 来切换到分支

如果你想创建一个新的分支同时切换到新创建的分支的话，可以通过 `git checkout -b <your-branch-name>` 来实现

#### git merge

使用 `git merge <分支名>` 把分支合并到当前分支

#### git rebase

Rebase 实际上就是取出一系列的提交记录，“复制”它们，然后在另外一个地方逐个的放下去。

Rebase 的优势就是可以创造更线性的提交历史，这听上去有些难以理解。如果只允许使用 Rebase 的话，代码库的提交历史将会变得异常清晰。

使用 `git rebase <分支名>` 把当前分支重新指向指定的分支

### 高级篇

#### 分离 HEAD

HEAD 是一个对当前检出记录的符号引用 —— 也就是指向你正在其基础上进行工作的提交记录。

HEAD 总是指向当前分支上最近一次提交记录。大多数修改提交树的 Git 命令都是从改变 HEAD 的指向开始的。

HEAD 通常情况下是指向分支名的（如 bugFix）。在你提交时，改变了 bugFix 的状态，这一变化通过 HEAD 变得可见。

分离的 HEAD 就是让其指向了某个具体的提交记录而不是分支名。在命令执行之前的状态如下所示：

HEAD -> master -> C1

HEAD 指向 master， master 指向 C1

git checkout C1

现在变成了

HEAD -> C1

使用 `git checkout <提交记录哈希值>` 分离HEAD

#### 相对引用（^）

通过指定提交记录哈希值的方式在 Git 中移动不太方便。在实际应用时，并没有像本程序中这么漂亮的可视化提交树供你参考，所以你就不得不用 `git log` 来查查看提交记录的哈希值。

并且哈希值在真实的 Git 世界中也会更长（译者注：基于 SHA-1，共 40 位）。例如前一关的介绍中的提交记录的哈希值可能是 `fed2da64c0efc5293610bdd892f82a58e8cbc5d8`。舌头都快打结了吧...

比较令人欣慰的是，Git 对哈希的处理很智能。你只需要提供能够唯一标识提交记录的前几个字符即可。因此我可以仅输入 `fed2` 而不是上面的一长串字符。

通过哈希值指定提交记录很不方便，所以 Git 引入了相对引用。这个就很厉害了!

使用相对引用的话，你就可以从一个易于记忆的地方（比如 `bugFix` 分支或 `HEAD`）开始计算。

相对引用非常给力，这里我介绍两个简单的用法：

* 使用 `^` 向上移动 1 个提交记录

* 使用 `~<num>` 向上移动多个提交记录，如 `~3`

首先看看操作符 (^)。

把这个符号加在引用名称的后面，表示让 Git 寻找指定提交记录的父提交。

所以 master^ 相当于“master 的父节点”。

master^^ 是 master 的第二个父节点

使用 `git checkout master^` 命令切换到 `master` 的父节点

你也可以将 `HEAD` 作为相对引用的参照。下面咱们就用 `HEAD` 在提交树中向上移动几次。

```bash
git checkout c3; git checkout HEAD^; git checkout HEAD^; git checkout HEAD^;
```

“~”操作符。

该操作符后面可以跟一个数字（可选，不跟数字时与 ^ 相同，向上移动一次），指定向上移动多少次。

```bash
git branch -f master HEAD~3
```

上面的命令会将 master 分支强制指向 HEAD 的第 3 级父提交。

#### 撤销变更

在 Git 里撤销变更的方法很多。和提交一样，撤销变更由底层部分（暂存区的独立文件或者片段）和上层部分（变更到底是通过哪种方式被撤销的）组成。我们这个应用主要关注的是后者。

主要有两种方法用来撤销变更 —— 一是 `git reset`，还有就是 `git revert`。接下来咱们逐个进行讲解。

* Git Reset

`git reset` 通过把分支记录回退几个提交记录来实现撤销改动。你可以将这想象成“改写历史”。`git reset` 向上移动分支，原来指向的提交记录就跟从来没有提交过一样。

* Git Revert

虽然在你的本地分支中使用 git reset 很方便，但是这种“改写历史”的方法对大家一起使用的远程分支是无效的哦！

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/gitrevert.jpg)_`git revert HEAD`_

上图一开始 `master` 指向 C2 ，执行 `git revert HEAD` 命令后指向C2'，在我们要撤销的提交记录后面居然多了一个新提交！

这是因为新提交记录 C2' 引入了更改 —— 这些更改刚好是用来撤销 C2 这个提交的。也就是说 C2' 的状态与 C1 是相同的。

revert 之后就可以把你的更改推送到远程仓库与别人分享啦。

### 移动提交记录

#### Git Cherry-pick

到现在我们已经学习了 Git 的基础知识 —— 提交、分支以及在提交树上移动。 这些概念涵盖了 Git 90% 的功能，同样也足够满足开发者的日常需求

然而, 剩余的 10% 在处理复杂的工作流时(或者当你陷入困惑时）可能就显得尤为重要了。接下来要讨论的这个话题是“整理提交记录” —— 开发人员有时会说“我想要把这个提交放到这里, 那个提交放到刚才那个提交的后面”, 而接下来就讲的就是它的实现方式，非常清晰、灵活，还很生动。

* `git cherry-pick <提交号>...`

如果你想将一些提交复制到当前所在的位置（`HEAD`）下面的话， Cherry-pick 是最直接的方式了。

这里有一个仓库, 我们想将 side 分支上的工作复制到 master 分支。

执行以下命令

```bash
git cherry-pick C2 C4
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-cherry-pick.gif)_`git cherry-pick C2 C4`_

我们只需要提交记录 C2 和 C4，所以 Git 就将被它们抓过来放到当前分支下了。 就是这么简单!

#### 交互式 rebase

当你知道你所需要的提交记录（并且还知道这些提交记录的哈希值）时, 用 cherry-pick 再好不过了 —— 没有比这更简单的方式了。

但是如果你不清楚你想要的提交记录的哈希值呢? 幸好 Git 帮你想到了这一点, 我们可以利用交互式的 rebase —— 如果你想从一系列的提交记录中找到想要的记录, 这就是最好的方法了。

交互式 `rebase` 指的是使用带参数 `--interactive` 的 rebase 命令, 简写为 `-i`

如果你在命令后增加了这个选项, Git 会打开一个 UI 界面并列出将要被复制到目标分支的备选提交记录，它还会显示每个提交记录的哈希值和提交说明，提交说明有助于你理解这个提交进行了哪些更改。

在实际使用时，所谓的 UI 窗口一般会在文本编辑器 —— 如 Vim —— 中打开一个文件。

当 rebase UI界面打开时, 你能做3件事:

* 调整提交记录的顺序（通过鼠标拖放来完成）

* 删除你不想要的提交（通过切换 pick 的状态来完成，关闭就意味着你不想要这个提交记录）

* 合并提交。

```bash
git rebase -i HEAD~4
```

### 杂项

#### 只取一个提交记录

来看一个在开发中经常会遇到的情况：我正在解决某个特别棘手的 Bug，为了便于调试而在代码中添加了一些调试命令并向控制台打印了一些信息。

这些调试和打印语句都在它们各自的提交记录里。最后我终于找到了造成这个 Bug 的根本原因，解决掉以后觉得沾沾自喜！

最后就差把 bugFix 分支里的工作合并回 master 分支了。你可以选择通过 fast-forward 快速合并到 master 分支上，但这样的话 master 分支就会包含我这些调试语句了。你肯定不想这样，应该还有更好的方式……

实际我们只要让 Git 复制解决问题的那一个提交记录就可以了。跟之前我们在“整理提交记录”中学到的一样，我们可以使用

* `git rebase -i`

* `git cherry-pick`

来达到目的。

#### 提交的技巧 #1

接下来这种情况也是很常见的：你之前在 `newImage `分支上进行了一次提交，然后又基于它创建了 `caption` 分支，然后又提交了一次。

此时你想对的某个以前的提交记录进行一些小小的调整。比如设计师想修改一下 `newImage` 中图片的分辨率，尽管那个提交记录并不是最新的了。

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git1.jpg)

我们可以通过下面的方法来克服困难：

* 先用 `git rebase -i` 将提交重新排序，然后把我们想要修改的提交记录挪到最前

* 然后用 `git commit --amend` 来进行一些小修改

* 接着再用 `git rebase -i` 来将他们调回原来的顺序

* 最后我们把 `master` 移到修改的最前端（用你自己喜欢的方法），就大功告成啦！

当然完成这个任务的方法不止上面提到的一种（我知道你在看 `cherry-pick` 啦），之后我们会多点关注这些技巧啦，但现在暂时只专注上面这种方法。 最后有必要说明一下目标状态中的那几个`'` —— 我们把这个提交移动了两次，每移动一次会产生一个 `'`；而 C2 上多出来的那个是我们在使用了 amend 参数提交时产生的，所以最终结果就是这样了。

也就是说，我在对比结果的时候只会对比提交树的结构，对于 `'` 的数量上的不同，并不纳入对比范围内。只要你的 `master` 分支结构与目标结构相同，我就算你通过。

以下是具体的执行命令

```bash
$ git rebase -i HEAD~2

$ git commit --amend

$ git rebase -i HEAD~2

$ git branch -f master C3''
```

#### 提交的技巧 #2

我们可以使用 rebase -i 对提交记录进行重新排序。只要把我们想要的提交记录挪到最前端，我们就可以很轻松的用 --amend 修改它，然后把它们重新排成我们想要的顺序。

但这样做就唯一的问题就是要进行两次排序，而这有可能造成由 rebase 而导致的冲突。下面还是看看 `git cherry-pick` 是怎么做的吧。

要在心里牢记 `cherry-pick` 可以将提交树上任何地方的提交记录取过来追加到 HEAD 上（只要不是 HEAD 上游的提交就没问题）。

以下是具体的执行命令

```bash
$ git checkout master

$ git cherry-pick C2

$ git commit --amend

$ git cherry-pick C3
```

#### Git Tag

分支很容易被人为移动，并且当有新的提交时，它也会移动。分支很容易被改变，大部分分支还只是临时的，并且还一直在变。

你可能会问了：有没有什么可以永远指向某个提交记录的标识呢，比如软件发布新的大版本，或者是修正一些重要的 Bug 或是增加了某些新特性，有没有比分支更好的可以永远指向这些提交的方法呢？

当然有了！Git 的 tag 就是干这个用的啊，它们可以（在某种程度上 —— 因为标签可以被删除后重新在另外一个位置创建同名的标签）永久地将某个特定的提交命名为里程碑，然后就可以像分支一样引用了。

更难得的是，它们并不会随着新的提交而移动。你也不能检出到某个标签上面进行修改提交，它就像是提交树上的一个锚点，标识了某个特定的位置。

`git tag v1 C1` 命令将这个标签命名为 v1，并且明确地让它指向提交记录 C1，如果你不指定提交记录，Git 会用 HEAD 所指向的位置。

#### Git Describe

由于标签在代码库中起着“锚点”的作用，Git 还为此专门设计了一个命令用来描述离你最近的锚点（也就是标签），它就是 `git describe`！

`Git Describe` 能帮你在提交历史中移动了多次以后找到方向；当你用 `git bisect`（一个查找产生 Bug 的提交记录的指令）找到某个提交记录时，或者是当你坐在你那刚刚度假回来的同事的电脑前时， 可能会用到这个命令。

`git describe` 的​​语法是：

`git describe <ref>`

`<ref>` 可以是任何能被 Git 识别成提交记录的引用，如果你没有指定的话，Git 会以你目前所检出的位置（`HEAD`）。

它输出的结果是这样的：

`<tag>_<numCommits>_g<hash>`

`tag` 表示的是离 `ref` 最近的标签， `numCommits `是表示这个 `ref` 与 `tag` 相差有多少个提交记录， `hash` 表示的是你所给定的 `ref` 所表示的提交记录哈希值的前几位。

当 `ref` 提交记录上有某个标签时，则只输出标签名称。

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/gitdescribe.jpg)

如上图

`git describe master` 会输出：

`v1_2_gC2`

`git describe side` 会输出：

`v2_1_gC4`

### 高级话题

#### 两个父节点

操作符 `^` 与 `~` 符一样，后面也可以跟一个数字。

但是该操作符后面的数字与 `~` 后面的不同，并不是用来指定向上返回几代，而是指定合并提交记录的某个父提交。还记得前面提到过的一个合并提交有两个父提交吧，所以遇到这样的节点时该选择哪条路径就不是很清晰了。

Git 默认选择合并提交的“第一个”父提交，在操作符 `^` 后跟一个数字可以改变这一默认行为。

举个例子，这里有一个合并提交记录。如果不加数字修改符直接检出 `master^`，会回到第一个父提交记录。

```bash
git checkout master^
```

(在我们的图示中，第一个父提交记录是指合并提交记录正上方的那个提交记录。)

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git2.jpg)_`git checkout master^`_

这正是我们都已经习惯的方法。

现在来试试选择另一个父提交……

```bash
git checkout master^2
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git3.jpg)_`git checkout master^2`_

看见了吧？我们回到了另外一个父提交上。

更厉害的是，这些操作符还支持链式操作！试一下这个：

```bash
git checkout HEAD~^2~2
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git4.jpg)_`git checkout HEAD~^2~2`_

#### 纠缠不清的分支

现在我们的 master 分支是比 one、two 和 three 要多几个提交。出于某种原因，我们需要把 master 分支上最近的几次提交做不同的调整后，分别添加到各个的分支上。

one 需要重新排序并删除 C5，two 仅需要重排排序，而 three 只需要提交一次，按顺序执行以下命令。

```bash
$ git checkout one

$ git cherry-pick C4 C3 C2

$ git checkout two

$ git cherry-pick C5 C4 C3 C2

$ git branch -f three C2
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-level3.gif)

## 远程仓库

远程仓库并不复杂, 在如今的云计算盛行的世界很容易把远程仓库想象成一个富有魔力的东西, 但实际上它们只是你的仓库在另个一台计算机上的拷贝。你可以通过因特网与这台计算机通信 —— 也就是增加或是获取提交记录

话虽如此, 远程仓库却有一系列强大的特性

首先也是最重要的的点, 远程仓库是一个强大的备份。本地仓库也有恢复文件到指定版本的能力, 但所有的信息都是保存在本地的。有了远程仓库以后，即使丢失了本地所有数据, 你仍可以通过远程仓库拿回你丢失的数据。

还有就是, 远程让代码社交化了! 既然你的项目被托管到别的地方了, 你的朋友可以更容易地为你的项目做贡献(或者拉取最新的变更)

现在用网站来对远程仓库进行可视化操作变得越发流行了(像 [GitHub](https://github.com/) 或 [Gitee](https://gitee.com/)), 但远程仓库永远是这些工具的顶梁柱, 因此理解其概念非常的重要!

### Push & Pull —— Git 远程仓库！

#### git clone

`git clone` 命令的作用是在本地创建一个远程仓库的拷贝（比如从 github.com）

#### 远程分支

你可能注意到的第一个事就是在我们的本地仓库多了一个名为 `origin/master` 的分支, 这种类型的分支就叫远程分支。由于远程分支的特性导致其拥有一些特殊属性。

远程分支反映了远程仓库(在你上次和它通信时)的状态。这会有助于你理解本地的工作与公共工作的差别 —— 这是你与别人分享工作成果前至关重要的一步.

远程分支有一个特别的属性，在你检出时自动进入分离 HEAD 状态。Git 这么做是出于不能直接在这些分支上进行操作的原因, 你必须在别的地方完成你的工作, （更新了远程分支之后）再用远程分享你的工作成果。

你可能想问这些远程分支的前面的 origin/ 是什么意思呢？好吧, 远程分支有一个命名规范 —— 它们的格式是:

* `<remote name>/<branch name>`

因此，如果你看到一个名为 `origin/master` 的分支，那么这个分支就叫 `master`，远程仓库的名称就是 `origin`。

#### Git Fetch

Git 远程仓库相当的操作实际可以归纳为两点：向远程仓库传输数据以及从远程仓库获取数据。既然我们能与远程仓库同步，那么就可以分享任何能被 Git 管理的更新（因此可以分享代码、文件、想法、情书等等）。

我们将学习如何从远程仓库获取数据 —— 命令如其名，它就是 `git fetch`。

你会看到当我们从远程仓库获取数据时, 远程分支也会更新以反映最新的远程仓库。在上一了我们已经提及过这一点了。

来看个实例，这里我们有一个远程仓库, 它有两个我们本地仓库中没有的提交。

执行 `git fetch`

C2,C3 被下载到了本地仓库，同时远程分支 `origin/master` 也被更新，反映到了这一变化

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-fetch.gif)_`git fetch`_

`git fetch` 完成了仅有的但是很重要的两步:

* 从远程仓库下载本地仓库中缺失的提交记录

* 更新远程分支指针(如 `origin/master`)

`git fetch` 实际上将本地仓库中的远程分支更新成了远程仓库相应分支最新的状态。

如果你还记得上一节中我们说过的，远程分支反映了远程仓库在你最后一次与它通信时的状态，`git fetch` 就是你与远程仓库通信的方式了！希望我说的够明白了，你已经了解 `git fetch` 与远程分支之间的关系了吧。

`git fetch` 通常通过互联网（使用 `http://` 或 `git://` 协议) 与远程仓库通信。

`git fetch` 并不会改变你本地仓库的状态。它不会更新你的 `master` 分支，也不会修改你磁盘上的文件。

理解这一点很重要，因为许多开发人员误以为执行了 `git fetch` 以后，他们本地仓库就与远程仓库同步了。它可能已经将进行这一操作所需的所有数据都下载了下来，但是并没有修改你本地的文件。

所以, 你可以将 `git fetch` 的理解为单纯的下载操作。

#### Git Pull

既然我们已经知道了如何用 `git fetch` 获取远程的数据, 现在我们学习如何将这些变化更新到我们的工作当中。

其实有很多方法的 —— 当远程分支中有新的提交时，你可以像合并本地分支那样来合并远程分支。也就是说就是你可以执行以下命令:

* `git cherry-pick origin/master`

* `git rebase origin/master`

* `git merge origin/master`

* 等等

实际上，由于先抓取更新再合并到本地分支这个流程很常用，因此 Git 提供了一个专门的命令来完成这两个操作。它就是我们要讲的 `git pull`。

来看个实例，这里我们有一个远程仓库, 它有一个我们本地仓库中没有的提交，执行 `git pull` 命令，它等效于 `git fetch` + `git merge origin/master`。

先下载了 C3, 然后通过 `git merge origin/master` 合并了这一提交记录。现在我们的 master 分支包含了远程仓库中的更新。

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-pull.gif)_`git pull`_

#### Git Push

OK，我们已经学过了如何从远程仓库获取更新并合并到本地的分支当中。这非常棒……但是我如何与大家分享我的成果呢？

嗯，上传自己分享内容与下载他人的分享刚好相反，那与 `git pull` 相反的命令是什么呢？`git push`！

`git push` 负责将你的变更上传到指定的远程仓库，并在远程仓库上合并你的新提交记录。一旦 `git push` 完成, 你的朋友们就可以从这个远程仓库下载你分享的成果了！

你可以将 `git push` 想象成发布你成果的命令。它有许多应用技巧，稍后我们会了解到，但是咱们还是先从基础的开始吧……

注意 —— `git push` 不带任何参数时的行为与 Git 的一个名为 `push.default` 的配置有关。它的默认值取决于你正使用的 Git 的版本，在你的项目中进行推送之前，最好检查一下这个配置。

#### 偏离的提交历史

假设你周一克隆了一个仓库，然后开始研发某个新功能。到周五时，你新功能开发测试完毕，可以发布了。但是 —— 天啊！你的同事这周写了一堆代码，还改了许多你的功能中使用的 API，这些变动会导致你新开发的功能变得不可用。但是他们已经将那些提交推送到远程仓库了，因此你的工作就变成了基于项目旧版的代码，与远程仓库最新的代码不匹配了。

这种情况下, `git push` 就不知道该如何操作了。如果你执行 `git push`，Git 应该让远程仓库回到星期一那天的状态吗？还是直接在新代码的基础上添加你的代码，亦或由于你的提交已经过时而直接忽略你的提交？

因为这情况（历史偏离）有许多的不确定性，Git 是不会允许你 `push` 变更的。实际上它会强制你先合并远程最新的代码，然后才能分享你的工作。

那该如何解决这个问题呢？很简单，你需要做的就是使你的工作基于最新的远程分支。

有许多方法做到这一点呢，不过最直接的方法就是通过 `rebase` 调整你的工作。咱们继续，看看怎么 `rebase`！

```bash
git fetch; git rebase origin/master; git push;
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-push1.gif)_`git fetch; git rebase origin/master; git push;`_

我们用 `git fetch` 更新了本地仓库中的远程分支，然后用 `rebase` 将我们的工作移动到最新的提交记录下，最后再用 `git push` 推送到远程仓库。

还有其它的方法可以在远程仓库变更了以后更新我的工作吗? 当然有，我们还可以使用 `merge`

尽管 `git merge` 不会移动你的工作（它会创建新的合并提交），但是它会告诉 Git 你已经合并了远程仓库的所有变更。这是因为远程分支现在是你本地分支的祖先，也就是说你的提交已经包含了远程分支的所有变化。

看下演示...

```bash
git fetch; git merge origin/master; git push;
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-push2.gif)_`git fetch; git merge origin/master; git push;`_

我们用 `git fetch` 更新了本地仓库中的远程分支，然后合并了新变更到我们的本地分支（为了包含远程仓库的变更），最后我们用 `git push` 把工作推送到远程仓库。

很好！但是要敲那么多命令，有没有更简单一点的？

当然 —— 前面已经介绍过 `git pull` 就是 `fetch` 和 `merge` 的简写，类似的 `git pull --rebase` 就是 `fetch` 和 `rebase` 的简写！

让我们看看简写命令是如何工作的。

```bash
git pull --rebase; git push;
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-push3.gif)_`git pull --rebase; git push;`_

跟之前结果一样，但是命令更短了。

换用常规的 `pull`

```bash
git pull; git push;
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-push4.gif)_`git pull; git push;`_

还是跟以前一样!

#### 锁定的Master(Locked Master)

如果你是在一个大的合作团队中工作, 很可能是master被锁定了, 需要一些Pull Request流程来合并修改。如果你直接提交(commit)到本地master, 然后试图推送(push)修改, 你将会收到这样类似的信息:

 `! [远程服务器拒绝] master -> master (TF402455: 不允许推送(push)这个分支; 你必须使用pull request来更新这个分支.)`

 远程服务器拒绝直接推送(push)提交到master, 因为策略配置要求 pull requests 来提交更新.

你应该按照流程,新建一个分支, 推送(push)这个分支并申请pull request,但是你忘记并直接提交给了master.现在你卡住并且无法推送你的更新.

解决办法是新建一个分支feature, 推送到远程服务器. 然后reset你的master分支和远程服务器保持一致, 否则下次你pull并且他人的提交和你冲突的时候就会有问题.

```bash
git reset origin/master; git checkout -b feature C2; git push origin feature;
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-push5.gif)_`git reset origin/master; git checkout -b feature C2; git push origin feature;`_

### Git 远程仓库高级操作

#### 合并特性分支

既然你应该很熟悉 fetch、pull、push 了，现在我们要通过一个新的工作流来测试你的这些技能。

在大型项目中开发人员通常会在（从 `master` 上分出来的）特性分支上工作，工作完成后只做一次集成。这跟前面课程的描述很相像（把 `side` 分支推送到远程仓库），不过本节我们会深入一些.

但是有些开发人员只在 `master` 上做 push、pull —— 这样的话 `master` 总是最新的，始终与远程分支 (`o/master`) 保持一致。

对于接下来这个工作流，我们集成了两个步骤：

* 将特性分支集成到 `master` 上

* 推送并更新远程分支

```bash
$ git fetch

$ git rebase o/master side1

$ git rebase side1 side2

$ git rebase side2 side3

$ git rebase side3 master

$ git push
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-push6.gif)_`合并特性分支`_

#### 合并远程仓库

为了 `push` 新变更到远程仓库，你要做的就是包含远程仓库中最新变更。意思就是只要你的本地分支包含了远程分支（如 `o/master`）中的最新变更就可以了，至于具体是用 `rebase` 还是 `merge`，并没有限制。

那么既然没有规定限制，为何前面几节都在着重于 `rebase` 呢？为什么在操作远程分支时不喜欢用 `merge` 呢？

在开发社区里，有许多关于 merge 与 rebase 的讨论。以下是关于 rebase 的优缺点：

* 优点 Rebase 使你的提交树变得很干净, 所有的提交都在一条线上

* 缺点 Rebase 修改了提交树的历史

比如, 提交 C1 可以被 rebase 到 C3 之后。这看起来 C1 中的工作是在 C3 之后进行的，但实际上是在 C3 之前。

一些开发人员喜欢保留提交历史，因此更偏爱 merge。而其他人（比如我自己）可能更喜欢干净的提交树，于是偏爱 rebase。仁者见仁，智者见智。

```bash
$ git checkout master

$ git pull

$ git merge side1

$ git merge side2

$ git merge side3

$ git push
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gits/git-push7.gif)_`合并远程仓库`_

#### 远程跟踪分支

Git 好像知道 `master` 与 `origin/master` 是相关的。当然这些分支的名字是相似的，可能会让你觉得是依此将远程分支 `master` 和本地的 `master` 分支进行了关联。这种关联在以下两种情况下可以清楚地得到展示：

* pull 操作时, 提交记录会被先下载到 `origin/master` 上，之后再合并到本地的 `master` 分支。隐含的合并目标由这个关联确定的。

* push 操作时, 我们把工作从 `master` 推到远程仓库中的 `master` 分支(同时会更新远程分支 `origin/master`) 。这个推送的目的地也是由这种关联确定的！

直接了当地讲，`master` 和 `origin/master` 的关联关系就是由分支的“remote tracking”属性决定的。`master` 被设定为跟踪 `origin/master` —— 这意味着为 `master` 分支指定了推送的目的地以及拉取后合并的目标。

你可能想知道 `master` 分支上这个属性是怎么被设定的，你并没有用任何命令指定过这个属性呀！好吧, 当你克隆仓库的时候, Git 就自动帮你把这个属性设置好了。

当你克隆时, Git 会为远程仓库中的每个分支在本地仓库中创建一个远程分支（比如 `origin/master`）。然后再创建一个跟踪远程仓库中活动分支的本地分支，默认情况下这个本地分支会被命名为 `master`。

克隆完成后，你会得到一个本地分支（如果没有这个本地分支的话，你的目录就是“空白”的），但是可以查看远程仓库中所有的分支（如果你好奇心很强的话）。这样做对于本地仓库和远程仓库来说，都是最佳选择。

这也解释了为什么会在克隆的时候会看到下面的输出：

`local branch "master" set to track remote branch "o/master"`