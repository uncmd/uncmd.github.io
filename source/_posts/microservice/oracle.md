---
title: Oracle
date: 2020-05-16 23:41:40
tags:
  - 数据库
  - 随笔
categories:
  - 微服务
---

## Oracle介绍

Oracle Database，又名Oracle RDBMS，或简称Oracle。是甲骨文公司的一款关系数据库管理系统。它是在数据库领域一直处于领先地位的产品。可以说Oracle数据库系统是目前世界上流行的关系数据库管理系统，系统可移植性好、使用方便、功能强，适用于各类大、中、小、微机环境。它是一种高效率、可靠性好的、适应高吞吐量的数据库方案。

## Oracle使用

### 锁表锁包查询

```sql
-- 查询锁包
SELECT 'alter system kill session ' || '''' || sid || ',' || serial# || '''immediate;', a.*
  FROM dba_ddl_locks a, v$session ss
 WHERE a.name LIKE '%cux_erp_qms_interface_pkg%'
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