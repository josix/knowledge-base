---
title: "Elasticsearch primary shard"
date: 2022-05-06T02:06
description: "Elasticsearch shard 是 [[Elasticsearch]] 最小的運作單元，每個 shard 持有一部分[[Elasticsearch index]] 的資料..."
---
- Elasticsearch shard 是 [[Elasticsearch]] 最小的運作單元，每個 shard 持有一部分[[Elasticsearch index]] 的資料。
- 每個 shard 都是 [[Lucene]] 的個體，自身便是一個完整搜索引擎（[[Search Engine]]）
- shard 是資料的容器（[[Container]]），其存放著許多的 [[Elasticsearch document]]，而 Shard 會被配置在 [[Elasticsearch node]] 中，形成 [[Elasticsearch cluster]]
- Elasticsearch shard 分為兩種分別是 [[Elasticsearch primary shard]] 和 [[Elasticsearch replica shard]]
- primary shard 的數量是在 [[Elasticsearch index]] 建立時固定下來的，後續不可再更動。
- 預設 [[Elasticsearch]] 會設定五個 primary shard
- 在建立 Index 時設定 shard 的參數如下：
	```
	PUT /blogs
	{
		"settings": {
			"number_of_shards": 3,
			"number_of_replicas": 1
		}
	}
	```
	![Pasted image 20210911011816.png](https://i.imgur.com/Ivp0W7x.png)
	由於 replica shard 未完全運作，因此 cluster 健康狀態是黃色的
- 新建立索引（[[indexed]]）的 [[Elasticsearch document]] 會先被放置在 primary shard 之後再會備份至 [[Elasticsearch replica shard]]