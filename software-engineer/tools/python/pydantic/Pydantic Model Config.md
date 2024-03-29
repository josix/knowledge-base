---
title: "Pydantic Model Config"
date: 2022-05-06T02:10
dg-publish: true
dg-permalink: "software-engineer/tools/python/pydantic/Pydantic Model Config"
---
- 可以透過定義在 [[Pydantic Model]] 或 [[Pydantic Dataclasses]] 中的 `Config` Class 控制 model 行為
- 選項
	- extra： 可以選擇 "allow", "forbid", "ignore" 或 `Extra` enum 的 value (`Extra.allow`) 將額外的屬性加入 model 初始化，"allow" 會允許加入額外的參數作為 model 屬性、"forbid" 會拒絕加入並顯示錯誤、"ignore" 會忽略錯誤並不加入該屬性。
	- orm_mode： 選擇是否啟用 [Pydantic ORM Mode]