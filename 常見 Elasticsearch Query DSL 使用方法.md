---
tags: Tool Sharing, draft
---
# 常見 Elasticsearch Query DSL 使用方法
[TOC]

---
## 先備知識
### Elasticsearch Query DSL (Domain Specific Language)
在 Elasticsearch 中執行搜尋，除了透過 `GET /_search` 帶入 query string 以外，Elasticsearch 也有提供較完整功能、彈性的 Query Language -- DSL (Domain-Specific Language) 用於面對各式各樣的搜尋情境。

DSL 由 JSON request body 組成，由兩種子句（clause）所組成：
- 葉查詢子句（leaf query clauses）: 主要用於取得指定欄位內容的子句，如 `match`、`term`、`range` query 等，可以獨立使用。
- 複合查詢子句（compound query clauses）: 由葉查詢子句或複合查詢子句組合而成，以有邏輯的結構結合了多個 query，例如 `bool`、`dis_max` query，或是影響其行為如 `constant_score` query。

### Query Context 和 Filter Context

在 DSL 中有兩種 Context 會影響查詢的結果：

#### Query Context
在此 Context，Elasticsearch 主要完成兩個工作：

1. 決定哪些文件是有匹配到的，透過計算 TF-IDF、BM25 等模型分數加上 Boosting 加權，得到有匹配的文件。
2. 計算匹配到的文件其相關性分數（relevance scores），相關性分數會在回傳時帶入至 `_score` 欄位。

每當有 `query` 參數帶入至 `search` API 的查詢子句時，query context 就會生效。

#### Filter Context

在 Filter Contexnt, Elasticsearch 會用於判斷哪些文件有符合過濾的子句，並不會特別計算分數，只會過濾掉文件。常用的 filter 會被 Elasticsearch cache 起來以提升效能。

每當有 `filter` 參數帶入至 `search` API 的查詢子句時，filter context 就會生效。例如 `bool` query 中的 `filter` 或 `must_not`、`constant_score` query 的 `filter` 或是 `filter` aggregation。

如下方的 search query， `query` 參數觸發 query context，而 `bool` 和 `match` 由於在 query context 便會用於計算文件分數，`filter` 參數會觸發 filter contexnt，`term` 和 `range` 由於在此 context 便不會對分數有影響並且會過濾掉不匹配的文件。
```
GET /_search
{
  "query": { 
    "bool": { 
      "must": [
        { "match": { "title":   "Search"        }},
        { "match": { "content": "Elasticsearch" }}
      ],
      "filter": [ 
        { "term":  { "status": "published" }},
        { "range": { "publish_date": { "gte": "2015-01-01" }}}
      ]
    }
  }
}
```

## Term Query 與 Full Text Query
### Term Level Query

### Full Text Query



## Reference
- [Elasticsearch DSL Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html#query-dsl)
- [Elasticsearch 7.0 Cookbook - Fourth Edition](https://www.packtpub.com/product/elasticsearch-7-0-cookbook-fourth-edition/9781789956504)
- [[Elasticsearch] 深入搜索](https://godleon.github.io/blog/Elasticsearch/Elasticsearch-advanced-search/) 



