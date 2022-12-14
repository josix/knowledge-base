---
title: "Filter Context"
date: 2022-05-06T02:07
dg-publish: true
dg-permalink: "software-engineer/tools/elasticsearch/Filter Context"
---
- 在 Filter Contexnt, [[Elasticsearch]] 會用於判斷哪些文件有符合過濾的子句，並不會特別計算分數，只會過濾掉文件。常用的 filter 會被 Elasticsearch cache 起來以提升效能。

- 每當有 `filter` 參數帶入至 `search` API 的查詢子句時，filter context 就會生效。例如 `bool` query 中的 `filter` 或 `must_not`、`constant_score` query 的 `filter` 或是 `filter` aggregation。
- 在 filter context 中，filter 會先過濾[[Elasticsearch document]]，減少文件的數量，再接續執行 query 的內容。