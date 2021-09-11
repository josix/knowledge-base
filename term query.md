- term query 用於完全匹配的情境下，並且執行相較快速
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
- For executing a [[term query]] as a filter, we need to use it wrapped in [[bool query]]. The preceding [[term query]] will be executed in the following way.
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
- Every field that is [[indexed]] in [[Lucene]] is converted into a fast search structure for its particular type.
	- The [[text field]] is split into [[tokens]], if analyzed or saved as a single token
	- The [[numeric fields]] are converted into their fastest binary representation
	- The date and [[datetime fields]] are converted into binary forms
- During a term query execution, all the documents matching the term are collected, and then they are sorted by score (the scoring depends on the [[Lucene]], similarity algorithm chosen by default [[BM25]])
- [[filter]] is preferred to the query when the score is not important (filter permissions, numerical values, ranges)
- In a filtered query, the [[filter]] applies first, narrowing the number of documents to be matched against the query, and then the query is applied      
- Representation of a phrase depending on several analyzers in the following table 
| Mapping Index     | Analyzer         | Tokens                                 |
| ----------------- | ---------------- | -------------------------------------- |
| "index":false     | (No Index)       | (No tokens)                            |
| "type": "keyword" | KeywordAnalyzer  | \["Peter's house is big"\]             |
| "type": "text"    | StandardAnalyzer | \["peter", "s", "house", "is", "big"\] |
- [[KeywordAnalyzer]], which is used as the default for the not tokenized field, saves the string unchanged as a single token
- [[StandardAnalyzer]], the default for the type="text" field, tokenizes on whitespaces and punctuation; every token is converted into lowercase.