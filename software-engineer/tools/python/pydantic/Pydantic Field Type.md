---
title: "Pydantic Field Type"
date: 2022-05-06T02:10
dg-publish: true
dg-permalink: "software-engineer/tools/python/pydantic/Pydantic Field Type"
---
- [[Pydantic]] 支援 Python 內建的[[Python typing]] 作為欄位的型態，但還有其他常見的型態會由 [[Pydantic Types]] 來補強，若還有需要自定義的型態也可以透過 [[Pydantic Custom Data Types]] 定義
- Python Standard Library ([[Python typing]])
	- [[typing.Optional]] ：[typing.Union]\[x, None\] 的簡寫，若為必填可以在帶入 ellipsis(...) 或 `Field(...)` ([[Pydantic Field function]])