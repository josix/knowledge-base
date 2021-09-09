---
tags: Tool Sharing, draft
---
# FastAPI 使用筆記

[TOC]

---

## User Guide
### Run Server
1. 開啟 `main.py` 寫入下列內容，並在 Terminal 執行 `uvicorn main:app --reload`
```python=
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}
```

- `main` 指的是 main.py module
- `app` 指的是 FastAPI 的實例
- `--reload` 選項是讓程式碼有變更時會自動重啟伺服器

2. 執行後會有下列 log 資訊：
```
INFO: Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO: Started reloader process [28720]
INFO: Started server process [28722]
INFO: Waiting for application startup.
INFO: Application startup complete.
```
3. 可以透過 curl 下 `curl -X GET http://127.0.0.1:8000` 驗證 response 應為
```json
{"message":"Hello World"}
```
4. FastAPI 會自動產生符合 OpenAPI 規範的 API 文件，可以透過瀏覽器進入 `http://127.0.0.1:8000/docs` (Swagger UI) 
> OpenAPI 規範 (OpenAPI Spefification, OAS) 定義了不論是人或是機器都可以理解的 REST API 的標準，其可以使用 JSON 或 YAML 格式內容包含可以使用的 entrypoint 及其操作 HTTP verb、操作參數，身份驗證方式等。

![](https://i.imgur.com/OFAKZV8.png)

另外也有 ReDoc 介面 `http://127.0.0.1:8000/redoc`
![](https://i.imgur.com/aKk8AsX.png)

透過產生如 Swagger 或是 ReDoc 兩種互動式 API 文件可以明確說明資料模型和 API 的 Schema。

### Path Parameters

1. 啟動以後接下來可以修該 entry_point 路徑


3. 
4. 


- Pydantic： 


## Reference
- [OpenAPI Specification](https://swagger.io/specification/)