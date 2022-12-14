---
title: "Okapi BM25"
date: 2022-05-06T02:09
dg-publish: true
dg-permalink: "data-science/Okapi BM25"
tags: search, tech
description: "Okapi BM25 是經典資訊檢索模型之一，也是 [[Elasticsearch]] [[Elasticsearch similarity]] 計算檢索[[相關性分數]]的預設演算法。BM 是 Best Matching 的縮寫，25 是其實驗參數配置所實驗的次數..."
---

Okapi BM25 是經典資訊檢索模型之一，也是 [[Elasticsearch]] [[Elasticsearch similarity]] 計算檢索[[相關性分數]]的預設演算法。BM 是 Best Matching 的縮寫，25 是其實驗參數配置所實驗的次數。

## BM25 算法淺析

BM25 的模型算式如下
$$
score(D, Q) = \sum_{i=1}^{n}IDF(q_i)\frac{f(q_i, D) \times (k_1 + 1)}{f(q_i, D) + k_1 \times (1-b+b\times\frac{fieldLen}{avgFieldLen})}
$$
其中 query Q 包含 terms $q_1, q_2, q_3, ..., q_n$
此算式中包含六個部分: $q_i, IDF(q_i), f(q_i, D), k_1, b, \frac{fieldLen}{avgFieldLen}$ 分別說明如下：

- $q_i$ 代表 query 第 $i^{th}$ 個 term，若query Q 為 `shane connelly` 則 $q_0$ 為 `shane`、 $q_1$ 為 `connelly`。
- $IDF(q_i)$ 是 term $q_i$ 的[[逆向檔案頻率 (IDF)]]是一個詞語是否常見的度量，相較 [[TF-IDF]] 的 IDF 定義，BM25 中的 IDF 除了考慮所有文件中 term 出現的頻率以外，會針對包含 term $q_i$ 的文件個數進行處罰扣分，而 TFIDF 中的 IDF 並不會，[[Lucene]]/BM25 中的 IDF 算式如下：
$$
	ln(1 + \frac{docCount - f(q_i) + 0.5}{f(q_i) + 0.5})
$$

> - docCount 是文件總數，在 Elasticsearch 中預設會是看所處的 [[Elasticsearch primary shard]] 中的文件，若透過 `search_type=dfs_query_then_fetch` 則會跨 shards 計算。
>- $f(q_i)$ 是包含 term $q_i$ 的文件數量。
>- 舉例來說，query Q = `shane connelly`, $q_0$ = `shane` 出現全部 4 個文件中，則 IDF("shane") = $ln(1+\frac{(4 - 4 + 0.5)}{4 + 0.5}) = ln(1 + \frac{0.5}{4.5}) = 0.10536$，$q_1$ = `connelly` 只出現在四個文件中的兩個文件中，則 IDF(`connelly`) = $ln(1 + \frac{4-2+0.5}{2+0.5}) = ln(1+\frac{2.5}{2.5}) = 0.69314$
>- IDF 代表著每個 term 的是否常見，若是常見的 term 如英文中的 `the`, `a`, `an` 等詞相較其他比較不常見的詞會貢獻較少的分數，例如 query `the president` 則 `the` 所貢獻的分數較低、`president` 貢獻分數較高，意味著 `president` 這個 term 的重要性高過 `the` 在檢索時應著重考慮。

- 分母中出現的 $\frac{fieldLen}{avgFieldLen}$ 是衡量文件字數長度的度量，若文件的總長度會長過所有文件的平均長度，則分母數字較大進而讓得分降低，反之文件長度短於所有文件的平均長度，則這個文件得分會提高，意味著未匹配到的字數越多要給予該文件較低的分數，舉例來說一個有三百頁的文件只提到關鍵字兩次，相較一篇提到關鍵字兩次的社群貼文，自然應該給這份三百頁的文件較低的分數。

- 參數 b 用於調整 $\frac{fieldLen}{avgFieldLen}$ 的重要度，因此當 b 越大，文件長度的重要性會被放大，長度大於平均長度的文件其分數會更高，而長度小於平均長度的文件其分數會被降低，預設 Elasticsearch 會設定 b = 0.75，當 b = 0 時，則完全不考慮文件長度的特徵。

- $f(q_i, D)$ 是計算 term $q_i$ 出現在文件 $D$ 中的次數，這邊意味著出現在文件中的 query term 越多，則該文件與 query 就越相關，則應該得到越多的分數。

- 參數 $k_1$ 用於調整 $f(q_i, D)$ 的飽和程度（term frequency saturation），限制當 term 出現的次數高過一定值之後，每多出現一次其所貢獻的分數會趨近 0 ，使得 term frequency 所貢獻的分數會如漸近線：

	![Pasted image 20211123133535.png](https://i.imgur.com/tmaNjlo.png)

	$k_1$ 的數值會影響該曲線的坡度，當 $tf() > k_1$ 時坡度會越來越平緩，而當 $tf() \leqq k_1$ 坡度越陡，因此當隨著 term 出現的次數由少到多，其每次貢獻的分數將會越來越少而達到飽和。意味著當文件中出現太多的 query term 時並不會提升太多分數。而當 $k_1$ 設定為 0 時，則代表只考慮 IDF，Elasticsearch 中的 $k_1$ 預設為 1.2。

## 在 Elasticsearch 中的 Okapi BM25

由於 [[Elasticsearch]] 預設會使用 5 個 [[Elasticsearch primary shard]] 作為一個 [[Elasticsearch index]]，每一個 shard 未必會收到所有的文件，因此在使用 BM25 作為計算的 [[相關性分數]] 時會受到其所考慮的文件並非是全局的而受到偏誤，例如在 shard 1 的文件較多則 IDF 所計算的分數可能就較其他文件較少的 shard 分數較低而誤判排序結果。

解決的方法有三：

- 放置更多的文件，透過文件數量的增加，每個 shard 中的 term 相關統計都會標準化，每個 shard 就會收到更多的文件，這樣就可以減少排序的誤判。

- 設定 `number_of_shards` 為 1，降低 shard 的數量，集中文件的放置位置，進而讓統計結果不會有偏誤。

- 在搜尋 request 加入 `?search_type=dfs_query_then_fetch`，這會首先搜集所有分散文件的詞頻（Distributed term frequency, DFS = Distributed frequency search），此結果會和設定只有一個 shard 的回傳 [[相關性分數]] 結果一樣，然而差別在於額外的往返在速度重要過搜尋結果的情境下是不必要的，另外在文件數量增加時這麼做會搜尋排序並不會有所提升反而犧牲效能。

## 於 Elasticsearch 中調整 Okapi BM25 參數
在進行調整 $k_1$ 和 $b$ 參數之前，還有很多修正是可以讓 Elasticsearch 的搜尋結果更貼近使用者意圖：
- 在 query 上可以更加精準，如增加 [[match_phrase query]]、[[bool query]] 。
-  加入同義詞，[[Elasticsearch Analyzer]] 中加入 [[synonym_graph filter]]，使搜尋自動將 query 轉換成帶入同義詞的 phrase query，例如 `ny` 換轉換為搜尋 `(ny OR ("new york"))`，conjunction 的邏輯也是可行的只需要在 query 中加入 `"auto_generate_synonyms_phrase_query" : false`，例如 `ny city` query  會被轉換為搜尋 `(ny OR (new AND york)) city` 搜尋。
- 加入 [[fuzzy query]] 、autosuggestions、stemming 等增加匹配到的召回的文件數量。
- 使用 [[function score query]] 調整 query 的算分方式，進行微調。

若這些都調教過，調整 $k_1$ 和 $b$ 參數才是加強搜尋結果的最後一哩路。首先要認知到並沒有最佳的唯一的 $k_1$ 和 $b$ 組合，需視使用情境以進行調整：

1. 首先要先知道 $k_1$ 和 $b$ 的可以調整範圍區間為何，在過去的實驗中證實較好的 $k_1$ 和 $b$ 的範圍分別是：
	- $k_1$ 常見設定在 0 - 3 之間，設定更高也是可行的，然而過去的實驗多數是設定在 0.5 - 2 之間有比較好的結果，調整方式多為增減 0.1 - 0.2 。
	- $b$ 的範圍區間為 0 - 1 之間，多數調整的方式為增減 0.1，多數實驗顯示將 $b$ 設定在 0.3 - 0.9 有較好的結果。
2. 接著要了解自己的搜尋情境適合什麼樣的參數組合：
	- 針對 $k_1$ 需要了解的是搜尋的情境是否認為匹配到的文章需要設定 term frequency 的飽和度，即使用者意圖是否會認為單篇文章出現越大量匹配到的詞會是好的結果，若搜尋的 corpus 多為長文如書籍、文章等，便有可能有較高的 term frequency 那麼 $k_1$ 便需要設定高一些才能顯現差異性，然而若用於搜尋商品敘述等，則頻繁出現匹配的 term 是一件比較奇怪的事情，則可以將 $k_1$ 調低一些。
	- 針對 $b$ 需要認知到搜尋的情境是否考慮到搜尋的情境會希望如何處理長文的搜尋結果，並且考慮文章的長短要如何影響詞的相關性。例如針對特定專長的技術文章，往往文章內容是有針對性的那麼文章的長度不論多長會是可以容忍的，反之文本的內容多是品質參差不齊的內文的話，越長的文章可能會是垃圾資訊或是無關的資訊，則可以調高 $b$ 以進行扣分。

### Explain API
在 Elasticsearch 中提供了 Explain API 解釋為什麼搜尋結果的給分是怎麼給的，只需要在一般的 query endpoint 後再加入 `_explain` 即可，例如
```
GET /people3/_doc/4/_explain
{
  "query": {
    "match": {
      "title": "shane connelly"
    }
  }
}
```
會得到如下結果：
```
{
  "_index": "people3",
  "_type": "_doc",
  "_id": "4",
  "matched": true,
  "explanation": {
    "value": 0.71437943,
    "description": "sum of:",
    "details": [
        {
          "value": 0.102611035,
          "description": "weight(title:shane in 3) [PerFieldSimilarity], result of:",
          "details": [
            {
              "value": 0.102611035,
              "description": "score(doc=3,freq=1.0 = termFreq=1.0\n), product of:",
              "details": [
                {
                  "value": 0.074107975,
                  "description": "idf, computed as log(1 + (docCount - docFreq + 0.5) / (docFreq + 0.5)) from:",
                  "details": [
                    {
                      "value": 6,
                      "description": "docFreq",
                      "details": []
                    }, {
                      "value": 6,
                      "description": "docCount",
                      "details": []
                    }
                  ]
				},
				{
                  "value": 1.3846153,
                  "description": "tfNorm, computed as (freq * (k1 + 1)) / (freq + k1 * (1 - b + b * fieldLength / avgFieldLength)) from:",
                  "details": [
                    {
                      "value": 1,
                      "description": "termFreq=1.0",
                      "details": []
                    },
					{
                      "value": 5,
					  "description": "parameter k1",
					  "details": []
					},
					{
					  "value": 1,
					  "description": "parameter b",
					  "details": []
				    },
					{
					  "value": 3,
					  "description": "avgFieldLength",
					  "details": []
					},
					{
					  "value": 2,
					  "description": "fieldLength",
					  "details": []
				    }
				  ]
				}
			  ]
		    }
	      ]
        },
  // others terms result...
  ]
}
```
可以清楚地看到每個 query term 會是怎麼在 BM25 中計算出來，包含參數的設定、IDF 值為多少，tfNorm 值為多少等，而 `_explain` 是 debug 工具，切記要在 production 模式關閉。