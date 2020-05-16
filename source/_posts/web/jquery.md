---
title: jQuery
date: 2020-05-16 23:41:40
tags:
  - jQuery
  - 笔记
categories:
  - Web
---

## jQuery 选择器

**选择器允许您对元素组或单个元素进行操作**

### 元素选择器

> $("p") 选取 &lt;p&gt; 元素。

> $("p.intro") 选取所有 class="intro" 的 &lt;p&gt; 元素。

> $("p#demo") 选取所有 id="demo" 的 &lt;p&gt; 元素。

### 属性选择器

> $("[href]") 选取所有带有 href 属性的元素。

> $("[href='#']") 选取所有带有 href 值等于 "#" 的元素。

> $("[href!='#']") 选取所有带有 href 值不等于 "#" 的元素。

> $("[href$='.jpg']") 选取所有 href 值以 ".jpg" 结尾的元素。

### CSS选择器

> $("p").css("background-color","red");

## jQuery 事件

| Event 函数          | 绑定函数至 |
| ------------- | ------------- |
| $(document).ready(function) | 将函数绑定到文档的就绪事件（当文档完成加载时）|
| $(selector).click(function) | 触发或将函数绑定到被选元素的点击事件 |
| $(selector).dblclick(function) | 触发或将函数绑定到被选元素的双击事件 |
| $(selector).focus(function) | 触发或将函数绑定到被选元素的获得焦点事件 |
| $(selector).mouseover(function) | 触发或将函数绑定到被选元素的鼠标悬停事件 |

**var jq=jQuery.noConflict()**，帮助您使用自己的名称（比如 jq）来代替 $ 符号。

## jQuery 效果

*speed 参数：可以取值 "slow"、"fast" 或毫秒*

*callback 参数：函数执行完成后所执行的函数名称*

### 滑动

> 向下滑动 slideDown(speed, callback);

> 向上滑动 slideUp(speed, callback);

> 上下切换 slideToggle(speed, callback);

### 淡入淡出

> 淡入 fadeIn(speed, callback);

> 淡出 fadeOut(speed, callback);

> 切换 fadeToggle(speed, callback);

> 渐变为给定的不透明度(0-1) fadeTo(speed, opacity, callback);

### 隐藏显示

> 隐藏 $(selector).hide(speed, callback);

> 显示 $(selector).show(speed, callback);

> 切换 $(selector).toggle(speed, callback);

### 动画

**语法：**

> $(selector).animate({params}, speed, callback);

必须的 params 参数定义形成动画的 CSS 属性

**实例**

```javascript
$("button").click(function(){
    $("div").animate({left:'250px'});
});
```

> <font color=#fe9955>提示：</font>默认的，所有HTML元素都有一个静态位置，且无法移动。如需对位置进行操作，要记得首先把元素的 CSS position 属性设置为 relative、fixed 或 absolute！

**操作多个属性**

```javascript
$("button").click(function(){
  $("div").animate({
    left:'250px',
    opacity:'0.5',
    height:'150px',
    width:'150px'
  });
});
```

也可以定义相对值（该值相对于元素的当前值）。需要在值的前面加上 += 或 -=：

```javascript
$("button").click(function(){
  $("div").animate({
    left:'250px',
    height:'+=150px',
    width:'+=150px'
  });
});
```

支持队列功能，会逐一调用队列中的动画

```javascript
$("button").click(function(){
  var div=$("div");
  div.animate({height:'300px',opacity:'0.4'},"slow");
  div.animate({width:'300px',opacity:'0.8'},"slow");
  div.animate({height:'100px',opacity:'0.4'},"slow");
  div.animate({width:'100px',opacity:'0.8'},"slow");
});
```

### 停止动画

**stop() 方法用于在动画或效果完成前对它们进行停止**

**语法**
> $(selector).stop(stopAll,goToEnd);

可选的 stopAll 参数规定是否清除动画队列，默认是 false，只停止活动的动画，队列中的动画会继续执行

可选的 gotoEnd 参数规定是否立即完成当前动画，默认是 false

### Callback 函数

**Callback 函数在当前函数完成之后执行**

```javascript
$("p").hide(1000,function(){
  alert("The paragraph is now hidden");
});
```

### Chaining

**Chaining 允许我们在一条语句中允许多个 jQuery 方法（在相同的元素上）**

```javascript
$("#p1").css("color","red").slideUp(2000).slideDown(2000);
```

## jQuery HTML

### jQuery 获取内容和属性

* text() - 设置或返回所选元素的文本内容

* html() - 设置或返回所选元素的内容（包括 HTML 标记）

* val()  - 设置或返回表单字段的值

```javascript
$("#btn1").click(function(){
  alert("Text: " + $("#test").text());
});
$("#btn2").click(function(){
  alert("HTML: " + $("#test").html());
});
$("#btn2").click(function(){
  alert("Value: " + $("#input").val());
});
```

> 获得链接中 href 属性的值

```javascript
$("button").click(function(){
  alert($("#w3s").attr("href"));
});
```

### jQuery 设置内容和属性

```javascript
$("#btn1").click(function(){
  $("#test1").text("Hello world!");
});
$("#btn2").click(function(){
  $("#test2").html("<b>Hello world!</b>");
});
$("#btn3").click(function(){
  $("#test3").val("Dolly Duck");
});
```

**text()、html() 以及 val() 的回调函数**

> 上面的三个 jQuery 方法：text()、html() 以及 val()，同样拥有回调函数。回调函数由两个参数：被选元素列表中当前元素的下标，以及原始（旧的）值。然后以函数新值返回您希望使用的字符串。

```javascript
$("#btn1").click(function(){
  $("#test1").text(function(i,origText){
    return "Old text: " + origText + " New text: Hello world!
    (index: " + i + ")";
  });
});

$("#btn2").click(function(){
  $("#test2").html(function(i,origText){
    return "Old html: " + origText + " New html: Hello <b>world!</b>
    (index: " + i + ")";
  });
});
```

**设置属性 - attr()**

```javascript
$("button").click(function(){
  $("#w3s").attr({
    "href" : "http://www.w3school.com.cn/jquery",
    "title" : "W3School jQuery Tutorial"
  });
});
```

**attr() 的回调函数**

> jQuery 方法 attr()，也提供回调函数。回调函数由两个参数：被选元素列表中当前元素的下标，以及原始（旧的）值。然后以函数新值返回您希望使用的字符串。

```javascript
$("button").click(function(){
  $("#w3s").attr("href", function(i,origValue){
    return origValue + "/jquery";
  });
});
```

### jQuery 添加元素

* append() - 在被选元素的结尾插入内容

* prepend() - 在被选元素的开头插入内容

* after() - 在被选元素之后插入内容

* before() - 在被选元素之前插入内容

```javascript
$("p").append("Some appended text.");
$("p").prepend("Some prepended text.");
$("img").after("Some text after");
$("img").before("Some text before");

function appendText()
{
var txt1="<p>Text.</p>";               // 以 HTML 创建新元素
var txt2=$("<p></p>").text("Text.");   // 以 jQuery 创建新元素
var txt3=document.createElement("p");  // 以 DOM 创建新元素
txt3.innerHTML="Text.";
$("p").append(txt1,txt2,txt3);         // 追加新元素
}
```

### jQuery 删除元素

* remove() - 删除被选元素（及其子元素）

* empty() - 从被选元素中删除子元素

```javascript
$("#div1").remove();
$("#div1").empty();

删除 class="italic" 的所有 <p> 元素
$("p").remove(".italic");
```

### jQuery 获取并设置 CSS 类

* addClass() - 向被选元素添加一个或多个类

* removeClass() - 从被选元素删除一个或多个类

* toggleClass() - 对被选元素进行添加/删除类的切换操作

* css() - 设置或返回样式属性

```javascript
$("button").click(function(){
  $("h1,h2,p").addClass("blue");
  $("div").addClass("important");
});

$("button").click(function(){
  $("#div1").addClass("important blue");
});

$("button").click(function(){
  $("h1,h2,p").removeClass("blue");
});

$("button").click(function(){
  $("h1,h2,p").toggleClass("blue");
});
```

**css 方法**

> $(selector).css("propertyname"); 返回首个匹配属性的值

> $(selector).css("propertyname","value"); 设置所有匹配的元素的值

> $(selector).css({"propertyname":"value","propertyname":"value",...}); 设置多个 CSS 属性

### jQuery 尺寸

* width() 方法设置或返回元素的宽度（不包括内边距、边框或外边距）

* height() 方法设置或返回元素的高度（不包括内边距、边框或外边距）

* innerWidth() 方法返回元素的宽度（包括内边距）

* innerHeight() 方法返回元素的高度（包括内边距）

* outerWidth() 方法返回元素的宽度（包括内边距和边框）

* outerHeight() 方法返回元素的高度（包括内边距和边框）

* outerWidth(true) 方法返回元素的宽度（包括内边距、边框和外边距）

* outerHeight(true) 方法返回元素的高度（包括内边距、边框和外边距）

方法里面添加参数用于设置尺寸

## jQuery 遍历

### 向上遍历 DOM 树

* parent() 方法返回被选元素的直接父元素

* parents() 方法返回被选元素的所有祖先元素，它一路向上直到文档的根元素 (&lt;html&gt;)

* parentsUntil() 方法返回介于两个给定元素之间的所有祖先元素

```javascript
$(document).ready(function(){
  $("span").parent();
});

$(document).ready(function(){
  $("span").parents("ul");
});

$(document).ready(function(){
  $("span").parentsUntil("div");
});
```

### 向下遍历 DOM 树

* children() 方法返回被选元素的所有直接子元素

* find() 方法返回被选元素的后代元素，一路向下直到最后一个后代

```javascript
返回类名为 "1" 的所有 <p> 元素，并且它们是 <div> 的直接子元素
$(document).ready(function(){
  $("div").children("p.1");
});

返回属于 <div> 后代的所有 <span> 元素
$(document).ready(function(){
  $("div").find("span");
});

返回 <div> 的所有后代
$(document).ready(function(){
  $("div").find("*");
});
```

### 在 DOM 树中水平遍历

* siblings() 方法返回被选元素的所有同胞元素

* next() 方法返回被选元素的下一个同胞元素

* nextAll() 方法返回被选元素的所有后面的同胞元素

* nextUntil() 方法返回介于两个给定参数之间的所有后面的同胞元素

* prev() 方法返回被选元素的上一个同胞元素

* prevAll() 方法返回被选元素的所有前面的同胞元素

* prevUntil() 方法返回介于两个给定参数之间的所有前面的同胞元素

```javascript
返回属于 <h2> 的同胞元素的所有 <p> 元素
$(document).ready(function(){
  $("h2").siblings("p");
});

返回 <h2> 的下一个同胞元素
$(document).ready(function(){
  $("h2").next();
});

返回 <h2> 的所有跟随的同胞元素
$(document).ready(function(){
  $("h2").nextAll();
});

返回介于 <h2> 与 <h6> 元素之间的所有同胞元素
$(document).ready(function(){
  $("h2").nextUntil("h6");
});
```

### jQuery 过滤

* first() 方法返回被选元素的首个元素

* last() 方法返回被选元素的最后一个元素

* eq() 方法返回被选元素中带有指定索引号的元素

* filter() 方法允许您规定一个标准。不匹配这个标准的元素会被从集合中删除，匹配的元素会被返回

* not() 方法返回不匹配标准的所有元素

> <font color=#fe9955>提示：</font>not() 方法与 filter() 相反

```javascript
选取首个 <div> 元素内部的第一个 <p> 元素
$(document).ready(function(){
  $("div p").first();
});

选择最后一个 <div> 元素中的最后一个 <p> 元素
$(document).ready(function(){
  $("div p").last();
});

索引号从 0 开始，因此首个元素的索引号是 0 而不是 1。
选取第二个 <p> 元素（索引号 1）
$(document).ready(function(){
  $("p").eq(1);
});

返回带有类名 "intro" 的所有 <p> 元素
$(document).ready(function(){
  $("p").filter(".intro");
});

返回不带有类名 "intro" 的所有 <p> 元素
$(document).ready(function(){
  $("p").not(".intro");
});
```

## jQuery AJAX

### jQuery load() 方法

load() 方法从服务器加载数据，并把返回的数据放入被选元素中

> $(selector).load(URL,data,callback);

必需的 URL 参数规定您希望加载的 URL。

可选的 data 参数规定与请求一同发送的查询字符串键/值对集合。

可选的 callback 参数是 load() 方法完成后所执行的函数名称。

> $("#div1").load("demo_test.txt");

```javascript
把 "demo_test.txt" 文件中 id="p1" 的元素的内容，加载到指定的 <div> 元素中
$("#div1").load("demo_test.txt #p1");
```

> 可选的 callback 参数规定当 load() 方法完成后所要允许的回调函数。回调函数可以设置不同的参数：

* responseTxt - 包含调用成功时的结果内容

* statusTXT - 包含调用的状态

* xhr - 包含 XMLHttpRequest 对象

```javascript
在 load() 方法完成后显示一个提示框。如果 load() 方法已成功，则显示“外部内容加载成功！”，而如果失败，则显示错误消息
$("button").click(function(){
  $("#div1").load("demo_test.txt",function(responseTxt,statusTxt,xhr){
    if(statusTxt=="success")
      alert("外部内容加载成功！");
    if(statusTxt=="error")
      alert("Error: "+xhr.status+": "+xhr.statusText);
  });
});
```

### jQuery - AJAX get() 和 post() 方法

- $.get() 方法通过 HTTP GET 请求从服务器上请求数据

- $.post() 方法通过 HTTP POST 请求从服务器上请求数据

- GET - 从指定的资源请求数据

    - GET 请求可被缓存

    - GET 请求保留在浏览器历史记录中

    - GET 请求可被收藏为书签

    - GET 请求不应在处理敏感数据时使用

    - GET 请求有长度限制

    - GET 请求只应当用于取回数据

- POST - 向指定的资源提交要处理的数据

    - POST 请求不会被缓存

    - POST 请求不会保留在浏览器历史记录中

    - POST 不能被收藏为书签

    - POST 请求对数据长度没有要求

> $.get(URL,callback);

> $.post(URL,data,callback);

```javascript
使用 $.get() 方法从服务器上的一个文件中取回数据
$("button").click(function(){
  $.get("demo_test.asp",function(data,status){
    alert("Data: " + data + "\nStatus: " + status);
  });
});

使用 $.post() 连同请求一起发送数据
$("button").click(function(){
  $.post("demo_test_post.asp",
  {
    name:"Donald Duck",
    city:"Duckburg"
  },
  function(data,status){
    alert("Data: " + data + "\nStatus: " + status);
  });
});
````