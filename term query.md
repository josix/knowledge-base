- term query 是 [[term level query]] 用於檢索欄位完全匹配給定 term 的[[Elasticsearch document]]，並且執行相較快速
- term query 相似 SQL 中的 [[equal query]]
- term query 執行的格式如下：
```
POST /mybooks/_search
 {
   "query": {
	 "term": {
	    "uuid": "33333"
	 }
    }
  }
```
- 在 [[Filter Context]] 下執行 term query, 只需要將 term 放進 [[bool query]] filter 參數中：
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
- 在 term query 執行時，所有欄位中有匹配到 term 的文件都會被搜集起來，並基於 [[Lucene]] 中的 [[Okapi BM25]] 模型算出 [[相關性分數]]，並依此分數排序。
- 檢索的[[相關性分數]]不太重要時，可以在 filter 中使用 term query 即可，以達到較好的效率，常見可用於過濾權限、數值欄位、數值範圍等。
- [[keyword field]] 和 [[text field]] 經過 [[Elasticsearch Analyzer]] 處理後存放於 [[Elasticsearch index]] 的內容
| Mapping Index     | Analyzer             | Tokens                                 |
| ----------------- | -------------------- | -------------------------------------- |
| "index":false     | (No Index)           | (No tokens)                            |
| "type": "keyword" | [[KeywordAnalyzer]]  | \["Peter's house is big"\]             |
| "type": "text"    | [[StandardAnalyzer]] | \["peter", "s", "house", "is", "big"\] |
- 由於 [[text field]] 預設使用 [[StandardAnalyzer]] 改變了內容（刪除標點符號、轉為小寫、將字串依照空格分成個別的 [[token]]），因此需避免使用 term query 搜尋 text field，應使用 [[match query]]  相較 term query 會將搜尋的 term 經過 [[Elasticsearch Analyzer]] 後再進行檢索。