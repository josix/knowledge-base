---
title: "Elasticsearch master node"
date: 2022-05-06T02:06
---
- Master node 負責管理 cluster 中的所有改變如 增刪 [[Elasticsearch index]]，增刪任何 [[Elasticsearch node]] 到 cluster 中。
- Master node 不會參與 [[Elasticsearch document]] 的增刪或搜尋，因此不會影響索引、檢索效能。
- 任何 [[Elasticsearch node]] 都可以成為 master node，若 master 故障，其他 node 會選舉出新的 master node，並將 [[Elasticsearch replica shard]] 接替成為 [[Elasticsearch primary shard]]