---
title: "Pydantic Model"
date: 2022-05-06T02:10
dg-publish: true
dg-permalink: "software-engineer/tools/python/pydantic/Pydantic Model"
---
## 什麼是 Model
- [[Pydantic]] 中定義物件的主要方式是透過繼承 `BaseModel` 定義的 model 來實現。
- Model 類似嚴格強型別語言中的 type，未知的資料經過 Model 的 parsing 和 validation 會產出保證符合自己 type 定義的實例。

### 定義必填欄位
- 若欄位需要為必填只需要加入 [[Python type annotation]] 即可，或是可以帶入 ellipsis(...) 或 [[Pydantic Field function]] Field(...)
	```python
	from pydantic import BaseModel, Field

	class Model(BaseModel):
		a: int
		b: int = ...
		c: int = Field(...)
	```
	
### Model 的屬性
- `parse_obj()`：類似 model 中的 __init__，但可以直接傳入 dict 不用透過 keyword 傳入。 