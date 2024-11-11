---
title: Lecture 1 - Modern OLAP Database Systems Notes
date: 2024-11-11T12:00
dg-publish: true
dg-permalink: software-engineer/cmu-advanced-database-systems/Lecture 1 - Modern OLAP Database Systems
description: ""
---
<!-- # 筆記本體 -->
## The History of OLAP

Problem: 隨著數據分析的需求上升，資料庫的使用者已經不再只單純透過 SQL 來查詢資料，而是需要更多的分析功能，最初多透過單體式的資料庫系統去滿足這些需求，讓資料庫管理這些原始資料、聚合資料如何被存放，然而隨著時間和需求變化，逐漸誕生了 OLAP (Online Analytical Processing) 為概念的資料庫系統逐漸設計出來。

- 1990s: Data Cubes - 在當時時空背景下所提供的資料儲存格式多為存於硬碟的 row store，使用情境多為 transaction-based 運算邏輯，並不完全適合於分析需求。對於 query 部分欄位的資料，資料庫不需要先將整個 row page 讀取出來，而是可以直接讀取部分欄位的資料。因此，Data Cubes 的概念被提出，將資料庫的資料預處理以多維度、聚合的 materialized view 的方式存放，但因為不容易透過 incremental 的方式維護，必須透過  預先定義並以 cronjob 形式更新這個 view，以提供了更多的分析功能，例如：roll-up, drill-down, slice, dice, pivot 等等。當時的 database system 如 Oracle, DB2, SQL Server 都有提供這樣的功能。

![Data Cubes](https://josix.tw/img/data-cubes.png)

- 2000s: Data Warehouse - 2000 年代開始，人們開始建立分析導向的資料庫，當時多數系統 fork 自 postgres 並重新根據 columnar 資料存取的需求設計了系統內部存放格式及 running execution 的方式。

  - 當時的 ParAccel 是 redshift 的前身，fork 自 PostgresDB 的 MonetDB 則是 DuckDB 的前身（MonetDB-lite）

  這個時候依然是以單體資料庫方式去管理資料的存放格式及存放方式。而相較於後續的 OLAP 設計架構，此時的系統設計為 [[Share-Nothing System]]。此時系統的使用方式多為 OLTP database 透過 ETL/CDC 的方式將資料複製到 Data Warehouse，然而 Data Warehouse 的 Schema 和運算資源依然需要事先定義準備。

![Data Warehouse](https://josix.tw/img/data-warhouse.png)

- 2010s: Share-Disks Engines:


<!-- 
## 延伸問題
## See Also

-->
## References

- [S2024 #01 - Modern OLAP Database Systems (CMU Advanced Database Systems)] (https://www.youtube.com/watch?v=5J-I8Mj8tss&list=PLSE8ODhjZXjYa_zX-KeMJui7pcN1rIaIJ)