---
title: "term level query"
date: 2022-05-06T02:11
dg-publish: true
dg-permalink: "software-engineer/tools/elasticsearch/term level query"
---
- Term level query 用於完全匹配 [[Elasticsearch document]] 中的特定欄位如 ip 位置、日期、價格、ID 等。不會再經過 [[Elasticsearch Analyzer]]，因此可以用於完全匹配且效能相較 [[full-text query]] 較快。
- Term level query 包含 [[term query]]、[[terms query]]、[[exists query]]、[[fuzzy query]]、[[prefix query]]、[[regexp query]]、[[wildcard query]] 等。