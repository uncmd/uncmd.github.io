---
title: Oracle数据库
date: 2020-05-11 20:41:40
tags:
  - 数据库
  - 随笔
categories:
  - 微服务
---

![](https://cdn.jsdelivr.net/gh/uncmd/MyResource/Hexo/images/oracle.jpg)

<!-- more -->

## Oracle介绍

Oracle Database，又名Oracle RDBMS，或简称Oracle。是甲骨文公司的一款关系数据库管理系统。它是在数据库领域一直处于领先地位的产品。可以说Oracle数据库系统是目前世界上流行的关系数据库管理系统，系统可移植性好、使用方便、功能强，适用于各类大、中、小、微机环境。它是一种高效率、可靠性好的、适应高吞吐量的数据库方案。

## Oracle使用

### 锁表锁包查询

```sql
-- 查询锁包
SELECT 'alter system kill session ' || '''' || sid || ',' || serial# || '''immediate;', a.*
  FROM dba_ddl_locks a, v$session ss
 WHERE a.name LIKE '%包名%'
   AND a.session_id = ss.sid;

--查看被锁的表
select p.spid,
       a.SERIAL#,
       c.object_name,
       b.session_id,
       b.oracle_username,
       b.os_user_name,
       'alter system kill session ' || '''' || p.SPID || ',' || a.SERIAL# || '''' || ';' strsql
  from v$process p, v$session a, v$locked_object b, all_objects c
 where p.addr = a.paddr
   and a.process = b.process
   and c.object_id = b.object_id;
   
   --查询锁表原因
select l.session_id sid, 
       s.serial#, 
       l.locked_mode, 
       l.oracle_username, 
       s.user#, 
       l.os_user_name, 
       s.machine, 
       s.terminal, 
       a.sql_text, 
       a.action
from v$sqlarea a, v$session s, v$locked_object l 
where l.session_id = s.sid 
   and s.prev_sql_addr = a.address 
order by sid, s.serial#;

-- --批量解锁语句生成
SELECT A.OBJECT_NAME,
       B.SESSION_ID,
       C.SERIAL#,
       'alter system kill session ''' || B.SESSION_ID || ',' || C.SERIAL# ||
       '''; ' AS A,
       C.PROGRAM,
       C.USERNAME,
       C.COMMAND,
       C.MACHINE,
       C.LOCKWAIT
  FROM ALL_OBJECTS A, V$LOCKED_OBJECT B, V$SESSION C
 WHERE A.OBJECT_ID = B.OBJECT_ID
   AND C.SID = B.SESSION_ID;
```

### Oracle把逗号分割的字符串转换为可放入in的条件语句的字符数列

```sql
使用例子：
SELECT rownum sn, column_value FROM TABLE(split(p_pmb, '|'));

split方法：

CREATE OR REPLACE FUNCTION "SPLIT" (p_list varchar2,p_sep varchar2 := ',') return type_split pipelined
IS
l_idx pls_integer;
v_list varchar2(4000) := p_list;

begin
      loop
           l_idx := instr(v_list,p_sep);
           if l_idx > 0 then
               pipe row(substr(v_list,1,l_idx-1));
               v_list := substr(v_list,l_idx+length(p_sep));
           else
                pipe row(v_list);
                exit;
           end if;

      end loop;


      return;
end split;


SELECT *
FROM TAB_A T1 
WHERE  T1.CODE  IN (
SELECT REGEXP_SUBSTR('589,321','[^,]+', 1, LEVEL) FROM DUAL
CONNECT BY REGEXP_SUBSTR('SMITH,ALLEN,WARD,JONES', '[^,]+', 1, LEVEL) IS NOT NULL
)

```

### Oracle杀掉进程的三种方式

1、ALTER SYSTEM KILL SESSION

关于KILL SESSION Clause ，如下官方文档描述所示，alter system kill session实际上不是真正的杀死会话，它只是将会话标记为终止。等待PMON进程来清除会话。

```sql
ALTER SYSTEM KILL SESSION 'sid,serial#'; --终止会话，不释放资源

alter system kill session 'sid serial#' immediate --终止会话，释放资源
```

2、ALTER SYSTEM DISCONNECT SESSION

ALTER SYSTEM DISCONNECT SESSION 杀掉专用服务器(DEDICATED SERVER)或共享服务器的连接会话，它等价于从操作系统杀掉进程。它有两个选项POST_TRANSACTION和IMMEDIATE， 其中POST_TRANSACTION表示等待事务完成后断开会话，IMMEDIATE表示中断会话，立即回滚事务。

```sql
ALTER SYSTEM DISCONNECT SESSION 'sid,serial#' POST_TRANSACTION;

ALTER SYSTEM DISCONNECT SESSION 'sid,serial#' IMMEDIATE;
```

3、KILL -9 SPID （Linux） 或 orakill ORACLE_SID spid　（Windows）

可以使用下面SQL语句找到对应的操作系统进程SPID，然后杀掉。

```sql
SELECT s.inst_id,
       s.sid,
       s.serial#,
       p.spid,
       s.username,
       s.program
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND';
```

> 杀掉操作系统进程是一件危险的事情，尤其不要误杀。所以在执行前，一定要谨慎确认。

在数据库如果要彻底杀掉一个会话，尤其是大事务会话，最好是使用ALTER SYSTEM DISCONNECT SESSION IMMEDIATE或使用下面步骤：

1、首先在操作系统级别Kill掉进程。

2、在数据库内部KILL SESSION

或者反过来亦可。这样可以快速终止进程，释放资源。