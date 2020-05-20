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

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/git.jpg)

<!-- more -->

## 一个有趣的开源项目，藏着git快速入门的秘密

开源地址：

https://github.com/pcottle/learnGitBranching

游戏地址：

https://learngitbranching.js.org/?demo

LearnGitBranching是一个git仓库可视化工具，沙箱以及一系列教育性教程和挑战。其主要目的是帮助开发人员通过可视化功能（在命令行上工作时缺少的功能）来理解git。这是通过具有不同级别的游戏来熟悉不同的git命令来实现的。

您可以在LearnGitBranching（LGB）中输入各种命令-处理命令时，附近的提交树将动态更新以反映每个命令的效果：

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/git.gif)

### git commit

用 `git commit` 来创建新的提交记录

### git branch

> 早建分支，多用分支

用 `git branch <分支名>` 来创建分支，用 `git checkout <分支名>` 来切换到分支

如果你想创建一个新的分支同时切换到新创建的分支的话，可以通过 `git checkout -b <your-branch-name>` 来实现

### git merge

使用 `git merge <分支名>` 把分支合并到当前分支

### git rebase

Rebase 实际上就是取出一系列的提交记录，“复制”它们，然后在另外一个地方逐个的放下去。

Rebase 的优势就是可以创造更线性的提交历史，这听上去有些难以理解。如果只允许使用 Rebase 的话，代码库的提交历史将会变得异常清晰。

使用 `git rebase <分支名>` 把当前分支重新指向指定的分支

### 分离 HEAD

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

### 相对引用（^）

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

### 撤销变更

在 Git 里撤销变更的方法很多。和提交一样，撤销变更由底层部分（暂存区的独立文件或者片段）和上层部分（变更到底是通过哪种方式被撤销的）组成。我们这个应用主要关注的是后者。

主要有两种方法用来撤销变更 —— 一是 `git reset`，还有就是 `git revert`。接下来咱们逐个进行讲解。

* Git Reset

`git reset` 通过把分支记录回退几个提交记录来实现撤销改动。你可以将这想象成“改写历史”。`git reset` 向上移动分支，原来指向的提交记录就跟从来没有提交过一样。

* Git Revert

虽然在你的本地分支中使用 git reset 很方便，但是这种“改写历史”的方法对大家一起使用的远程分支是无效的哦！

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/gitrevert.jpg)

上图一开始 `master` 指向 C2 ，执行 `git revert HEAD` 命令后指向C2'，在我们要撤销的提交记录后面居然多了一个新提交！

这是因为新提交记录 C2' 引入了更改 —— 这些更改刚好是用来撤销 C2 这个提交的。也就是说 C2' 的状态与 C1 是相同的。

revert 之后就可以把你的更改推送到远程仓库与别人分享啦。

### Git Cherry-pick

到现在我们已经学习了 Git 的基础知识 —— 提交、分支以及在提交树上移动。 这些概念涵盖了 Git 90% 的功能，同样也足够满足开发者的日常需求

然而, 剩余的 10% 在处理复杂的工作流时(或者当你陷入困惑时）可能就显得尤为重要了。接下来要讨论的这个话题是“整理提交记录” —— 开发人员有时会说“我想要把这个提交放到这里, 那个提交放到刚才那个提交的后面”, 而接下来就讲的就是它的实现方式，非常清晰、灵活，还很生动。

* `git cherry-pick <提交号>...`

如果你想将一些提交复制到当前所在的位置（`HEAD`）下面的话， Cherry-pick 是最直接的方式了。

这里有一个仓库, 我们想将 side 分支上的工作复制到 master 分支。

执行以下命令

```bash
git cherry-pick C2 C4
```

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/git-cherry-pick.gif)

我们只需要提交记录 C2 和 C4，所以 Git 就将被它们抓过来放到当前分支下了。 就是这么简单!

### 交互式 rebase

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

### 只取一个提交记录

来看一个在开发中经常会遇到的情况：我正在解决某个特别棘手的 Bug，为了便于调试而在代码中添加了一些调试命令并向控制台打印了一些信息。

这些调试和打印语句都在它们各自的提交记录里。最后我终于找到了造成这个 Bug 的根本原因，解决掉以后觉得沾沾自喜！

最后就差把 bugFix 分支里的工作合并回 master 分支了。你可以选择通过 fast-forward 快速合并到 master 分支上，但这样的话 master 分支就会包含我这些调试语句了。你肯定不想这样，应该还有更好的方式……

实际我们只要让 Git 复制解决问题的那一个提交记录就可以了。跟之前我们在“整理提交记录”中学到的一样，我们可以使用

* `git rebase -i`

* `git cherry-pick`

来达到目的。

### 提交的技巧 #1

接下来这种情况也是很常见的：你之前在 `newImage `分支上进行了一次提交，然后又基于它创建了 `caption` 分支，然后又提交了一次。

此时你想对的某个以前的提交记录进行一些小小的调整。比如设计师想修改一下 `newImage` 中图片的分辨率，尽管那个提交记录并不是最新的了。

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/git1.jpg)

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

### 提交的技巧 #2

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

### Git Tag