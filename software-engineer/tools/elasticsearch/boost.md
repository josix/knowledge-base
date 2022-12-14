---
title: "boost"
date: 2022-05-06T02:05
dg-publish: true
dg-permalink: "software-engineer/tools/elasticsearch/boost"
description: "boost 在 [[terms query]] 中用於拉高特定匹配到欄位的權重，並提高最終文件算分的總分，該值介於 0 到 1.0 之間會調低[[相關性分數]]，大於 1.0 會提高 [[相關性分數]]..."
---
boost 在 [[terms query]] 中用於拉高特定匹配到欄位的權重，並提高最終文件算分的總分，該值介於 0 到 1.0 之間會調低[[相關性分數]]，大於 1.0 會提高 [[相關性分數]]。