---
tags: search, tech
---

# Okapi BM25

Okapi BM25 是一個文字探勘的模型之一，也是 [[Elasticsearch]] 預設的 [[Elasticsearch similarity]] 演算法之一。



## 在 Elasticsearch 中的 Okapi BM25

由於 [[Elasticsearch]] 預設會使用 5 個 [[Elasticsearch primary shard]] 作為一個 [[Elasticsearch index]]，每一個 shard 未必會收到所有的文件，因此在使用 BM25 作為計算的 [[相關性分數]] 時會受到其所考慮的文件並非是全局的而受到偏誤，例如在 shard 1 的文件較多則 IDF 所計算的分數可能就較其他文件較少的 shard 分數較低而誤判排序結果。

解決的方法有三：

- 放置更多的文件，透過文件數量的增加，每個 shard 中的 term 相關統計都會標準化，每個 shard 就會收到更多的文件，這樣就可以減少排序的誤判。

- 設定 `number_of_shards` 為 1，降低 shard 的數量，集中文件的放置位置，進而讓統計結果不會有偏誤。

- 在搜尋 request 加入 `?search_type=dfs_query_then_fetch`，這會首先搜集所有分散文件的詞頻（Distributed term frequency, DFS = Distributed frequency search），此結果會和設定只有一個 shard 的回傳 [[相關性分數]] 結果一樣，然而差別在於額外的往返在速度重要過搜尋結果的情境下是不必要的，另外在文件數量增加時這麼做會搜尋排序並不會有所提升反而犧牲效能。
