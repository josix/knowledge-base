---
title: "Elasticsearch cluster"
date: 2022-05-06T02:06
---
- Elasticsearch cluster 由一個或多個有著相同 `cluster.name` 的 [[Elasticsearch node]] 組成，cluster 分散資料至這些 node 中。
 - 使用者可以存取 [[Elasticsearch cluster]] 中的任何 [[Elasticsearch node]] 包含 [[Elasticsearch master node]]，所有的 node 都知道 [[Elasticsearch document]] 的位置並可以直接轉發請求到該位置，並會再接收結果並傳送回客戶端。
- Elasticsearch cluster 的健康可以透過 `GET /_cluster/health` API 查看，其狀態包含紅、黃、綠三種顏色。綠色代表所有的 [[Elasticsearch primary shard]] 和 [[Elasticsearch replica shard]] 都正常運作、黃色代表所有的 primary shard 是正常運作的但並非所有 replica shard 都正常運作、紅色則代表並沒有所有的 primary shard 和 replica shard 都正常運作。