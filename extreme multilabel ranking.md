## 什麼是 Extreme Multilable Ranking
Extreme Multilable Ranking (XMR) 是一個分類任務，其主要任務為對於給予的輸入為其從龐大的候選類別中選擇一個適合的標記，Label、Input Instance 的數量通常為萬至百萬級別。常見的 XMR 情境包含在針對文件進行分類將其分類到適合的主題，並標記該文件的主題、也常見於對於商品進行標記所屬類別，隨著使用者可以自訂的 label 越多，便是屬於此分類任務。

在 2021 年四月，Amazon 提出 [[PECOS]] 框架以嘗試解決次問題，效能相較神經網路方法、過去經典方法都高，且效率高可應用於 real-time 服務。