---
tags: Tool Sharing, draft
---
# 常見 Elasticsearch Query DSL 使用方法

## 先備知識
### [[Elasticsearch Query DSL]] (Domain Specific Language)
在 [[Elasticsearch]] 中執行搜尋，除了透過 `GET /_search` 帶入 query string 以外，Elasticsearch 也有提供較完整功能、彈性的 Query Language -- DSL (Domain-Specific Language) 用於面對各式各樣的搜尋情境。

DSL 由 JSON request body 組成，由兩種子句（clause）所組成：
- 葉查詢子句（leaf query clauses）: 主要用於取得指定欄位內容的子句，如 `match`、`term`、`range` query 等，可以獨立使用。
- 複合查詢子句（compound query clauses）: 由葉查詢子句或複合查詢子句組合而成，以有邏輯的結構結合了多個 query，例如 `bool`、`dis_max` query，或是影響其行為如 `constant_score` query。

### Query Context 和 Filter Context

在 DSL 中有兩種 Context 會影響查詢的結果：

#### Query Context
在此 Context，Elasticsearch 主要完成兩個工作：

1. 決定哪些文件是有匹配到的，透過計算 TF-IDF、BM25 等模型分數加上 Boosting 加權，得到有匹配的文件。
2. 計算匹配到的文件其[[相關性分數]]（relevance scores），[[相關性分數]]會在回傳時帶入至 `_score` 欄位。

每當有 `query` 參數帶入至 `search` API 的查詢子句時，query context 就會生效。

#### [[Filter Context]]

在 Filter Contexnt, Elasticsearch 會用於判斷哪些文件有符合過濾的子句，並不會特別計算分數，只會過濾掉文件。常用的 filter 會被 Elasticsearch cache 起來以提升效能。filter 會先過濾文件，減少文件的數量，再接續執行 query 的內容。

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

## Term Level Query 與 Full Text Query
### [[term level query]]
Term level query 用於完全匹配 [[Elasticsearch document]] 中的特定欄位如 ip 位置、日期、價格、ID 等。由於不會再經過 [[Elasticsearch Analyzer]]，因此可以用於完全匹配且效能相較 [[full-text query]] 較快。常見的 term level query 包含 [[term query]]、[[terms query]]、[[exists query]]、[[fuzzy query]]、[[prefix query]]、[[regexp query]]、[[wildcard query]] 等。

#### [[term query]]
term query 用於檢索欄位內容完全匹配給定 term 的 [[Elasticsearch document]]，類似 SQL 中的 equal query，執行 term query 只需要在 query 中帶入 `term` 參數：
```
POST /mybooks/_search
{
  "query": {
    "term": {
	  "uuid": "1234",
	}
  }
}
```
在 term query 執行時，所有欄位中有匹配到 term 的文件都會被搜集起來，並基於 [[Lucene]] 中的 [[Okapi BM25]] 模型算出 [[相關性分數]]，並依此分數排序。

若要在 [[Filter Context]] 下執行 term query, 只需要將 term 放進 [[bool query]] filter 參數中：
```
POST /mybooks/_search
{
  "query": {
    "bool": {
	  "filter": {
	    "term": {
		  "uuid": "33333"
		}
	  }
	}
  }
}
```
當檢索的[[相關性分數]]不太重要時，可以在 filter 中使用 term query 即可，以達到較好的效率，常見可用於過濾權限、數值欄位、數值範圍等。

需要注意的是，由於 [[text field]] 預設使用 [[StandardAnalyzer]] 存放的內容會將句子轉為 [[token]]（會刪除標點符號、轉為小寫並將字串依照空格分成單一的 [[token]]，見下表），因此需避免使用 term query 搜尋 text field，應使用 [[match query]]  相較 term query 會將搜尋的 term 經過 [[Elasticsearch Analyzer]] 後再進行檢索。

| Mapping Index     | Analyzer             | Tokens                                 |
| ----------------- | -------------------- | -------------------------------------- |
| "index":false     | (No Index)           | (No tokens)                            |
| "type": "keyword" | [[KeywordAnalyzer]]  | \["Peter's house is big"\]             |
| "type": "text"    | [[StandardAnalyzer]] | \["peter", "s", "house", "is", "big"\] |

#### [[terms query]]
terms query 類似 term query 差別在於可以用於搜尋多個完全匹配的 term ，另外也可以可以透過 [[bool query]] 在 [[Filter Context]] 進行過濾，terms 類似 SQL 中 where 子句的 in 關鍵字，例如：`Select * from *** where color in ("red", "green")`

執行 terms query 的範例如下：
```
POST /mybooks/_search
{
  "query": {
    "terms": {
	  "uuid": [
	    "3333",
		"2222"
	  ]
	}
  }
}
```

terms query 支援額外的參數包含：
	- [[minimum_match]]/[[minimum_should_match]]：用於決定最少希望匹配到的 term 數量。
	- [[boost]]：用於拉高特定匹配到欄位的權重，並提高最終文件算分的總分，該值介於 0 到 1.0 之間會調低[[相關性分數]]，大於 1.0 會提高 [[相關性分數]]。
範例如下：
```
"terms": {
  "fruit": [
	"apple",
	"banana",
	"orange"
  ],
  "minimum_should_match": 2,
  "boost": 1.0,
}
```
### [[full-text query]]
#### [[match query]]
#### [[multi_match query]]
#### [[match_phrase query]]
#### [[query string query]]
#### [[common terms query]]
### [[Compound Query ]]
#### [[bool query]]
#### [[function score query]]
#### [[constant score query]]
#### [[disjunction max query]]

## Reference
- [Elasticsearch DSL Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html#query-dsl)
- [Elasticsearch 7.0 Cookbook - Fourth Edition](https://www.packtpub.com/product/elasticsearch-7-0-cookbook-fourth-edition/9781789956504)
- [[Elasticsearch] 深入搜索](https://godleon.github.io/blog/Elasticsearch/Elasticsearch-advanced-search/) 



