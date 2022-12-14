---
title: "Pydantic validator"
date: 2022-05-06T02:10
dg-publish: true
dg-permalink: "software-engineer/tools/python/pydantic/Pydantic validator"
---
- 設定預設值給 `Optional` 欄位可以透過 validator:
```python
class User(BaseModel):
    name: Optional[str] = ''
    password: Optional[str] = ''

    class Config:
        validate_assignment = True

    @validator('name')
    def set_name(cls, name):
        return name or 'foo'
```
