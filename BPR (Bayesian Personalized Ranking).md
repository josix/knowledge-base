---
tags: recsys, thesis
---

# BPR (Bayesian Personalized Ranking)

BPR （Bayesian Personalized Ranking）模型為 [[推薦系統]] 中 [[協同過濾]] 策略的模型之一，基於 [[Matrix Factorization Model]] 模型等 Latent factor model，BPR 模型以物品的排序為模型的訓練目標，而非只針對使用者、物品之間的評分進行訓練。因此在物品推薦任務使用者只在乎系統推薦什麼樣的物品，因此針對符合使用者過往的排序進行訓練更加貼近使用情境。除此以外 BPR 的目標函式會基於最大化[[貝氏定理]]的事後機率（maximum posterior probability）來求得最佳排序所需的參數（user/item latent factor）。

BPR 認為個人化推薦系統為針對每位使用者產生ㄧ個排序的物品清單，該物品清單的產出是基於使用者過往與系統的互動的隱性回饋（Implicit feedback）諸如歷史購買紀錄、瀏覽紀錄等，然而此種使用者紀錄在系統資料量相對物品總數是稀少的，也因此 BPR 的應用情境除了考慮到上述被觀測到的正回饋（observed positive feedback）外，也會針對未被觀測到缺少（missing value）的使用者互動行為（未來可能購買）及實際上使用者的負面回饋（real negative feedback）。

## 模型公式

$U$ 為系統中的使用者集合、$I$ 為系統中的物品集合，所觀測到的所有隱性回饋集合為 $S \subseteq U \times I$ ，個人化推薦的目的即為針對不同使用者產生一個排序好的物品集合 $>_u \subset I \times I$，其中 $>_u$ 需符合下列三點特點以符合[[全序關係]]：
1. 完全性（totality）
$$\forall\ i, j \in I: i \neq j \implies i  >_u j \lor j >_u i$$
2. 反對稱性（atisymmetry）
$$\forall\ i, j \in I: i >_u j \land j >_u i \implies i = j $$
3. 遞遺性（transitivity）
$$\forall\ i, j, k \in I: i >_u j \land j >_u k \implies i >_u k
$$






