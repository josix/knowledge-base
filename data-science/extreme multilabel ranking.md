---
title: "extreme multilabel ranking"
date: 2022-05-06T02:06
dg-publish: true
dg-permalink: "data-science/extreme multilabel ranking"
description: "Extreme Multilable Ranking (XMR) 是一個分類任務，其主要任務為對於給予的輸入為其從龐大的候選類別中選擇一個適合的標記，Label、Input Instance 的數量通常為萬至百萬級別。常見的 XMR 情境包含在針對文件進行分類將其分類到適合的主題，並標記該文件的主題、也常見於對於商品進行標記所屬類別，在動態的廣告投放上，每個商品對應著大量可選的投標關鍵字，而在 Question Answering 的情境中一個問題會有大量可能的回答段落..."
---
## 什麼是 Extreme Multilable Ranking
Extreme Multilable Ranking (XMR) 是一個分類任務，其主要任務為對於給予的輸入為其從龐大的候選類別中選擇一個適合的標記，Label、Input Instance 的數量通常為萬至百萬級別。常見的 XMR 情境包含在針對文件進行分類將其分類到適合的主題，並標記該文件的主題、也常見於對於商品進行標記所屬類別，在動態的廣告投放上，每個商品對應著大量可選的投標關鍵字，而在 Question Answering 的情境中一個問題會有大量可能的回答段落。

此任務的困難之處在於有龐大的 label output space，因此訓練資料呈現長尾效應，只有極少數的 label 可以匹配到較多的 instance。

在 2021 年四月，Amazon 提出 [[PECOS]] 框架以嘗試解決次問題，效能相較神經網路方法、過去經典方法都高，且效率高可應用於 real-time 服務。

## 公式化定義
給定訓練資料
$$\{(x_i, y_i : i = 1, ..., n)\}$$ 
其中
$$x_i \in \mathbb{R}^d$$
為第 i 個 instance 的 d 維特徵向量
$$ y_i \in \{0, 1\}^L, \mathcal{Y} \equiv \{1,...,l,...L\}$$
代表所有 instance 對應的 label (草寫大寫 Y 的元素) 都會被映射到值為零或一的空間
而在 XMR 問題中 n, d, L 的數量都大至百萬級別甚至更高。而希望透過目標函數
$$
f(x, l): \mathbb{R}^d \times \mathcal{Y} \rightarrow \mathbb{R}
$$
從 input instance (x) 和對應 label (l) 所得到的[[相關性分數]]，用於判斷哪些哪些 label 與哪些 instance 較相關，而在 XMR 的問題中只有顯著的最高前 b 個分數較有判斷意義，因此定義前 b 高的相關性分數的 lable 由下函數推斷：
$$
f_b(x) = \mathop{\arg\max}_{S\subset\mathcal{Y}:|S| = b}\sum_{l \in S} f(x, l)
$$

## 模型注意事項
檢視模型的可行性需考慮以下幾點：
- 品質：在 inference 時函數針對未見過的 instance 預測效果是否也很好
- 訓練效率：在訓練模型時是否有效率，時間空間複雜度是否夠低
- 推斷效率：在推斷階段時是否夠快以符合即時的需求
- 基礎建設的成本：訓練和推斷時所花費的計算資源成本是否夠低