---
tags: recsys, thesis
---

# BPR (Bayesian Personalized Ranking)

BPR （Bayesian Personalized Ranking）模型為 [[推薦系統]] 中 [[協同過濾]] 策略的模型之一，基於 [[Matrix Factorization Model]] 模型等 Latent factor model，BPR 模型以物品的排序為模型的訓練目標，而非只針對使用者、物品之間的評分進行訓練。在物品推薦任務中使用者只在乎系統推薦什麼樣的物品，針對符合使用者過往的排序進行訓練更加貼近使用情境。除此以外 BPR 的目標函式會基於最大化[[貝氏定理]]的事後機率（maximum posterior probability）來求得最佳排序所需的參數（user/item latent factor）。

BPR 認為個人化推薦系統為針對每位使用者產生ㄧ個排序的物品清單，該物品清單的產出是基於使用者過往與系統的互動的隱性回饋（Implicit feedback）諸如歷史購買紀錄、瀏覽紀錄等，然而此種使用者紀錄在系統資料量相對物品總數是稀少的，也因此 BPR 的應用情境除了考慮到上述被觀測到的正回饋（observed positive feedback）外，也會針對未被觀測到缺少（missing value）的使用者互動行為（未來可能購買）及實際上使用者的負面回饋（real negative feedback）進行考量。

## 模型公式

$U$ 為系統中的使用者集合、$I$ 為系統中的物品集合，所觀測到的所有隱性回饋集合為 $S \subseteq U \times I$ ，個人化推薦的目的即為針對不同使用者產生一個排序好的物品集合 $>_u \subset I \times I$，其中 $>_u$ 需符合下列三點特點以符合[[全序關係]]：

1. 完全性（totality）
$$\forall\ i, j \in I: i \neq j \implies i  >_u j \lor j >_u i$$
2. 反對稱性（atisymmetry）
$$\forall\ i, j \in I: i >_u j \land j >_u i \implies i = j $$
3. 遞遺性（transitivity）
$$\forall\ i, j, k \in I: i >_u j \land j >_u k \implies i >_u k
$$

另外定義了使用者互動過的物品集合 $I_u^+$ 和與物品互動過的使用者集合 $U_i^+$：
$$I_u^+ \coloneqq \{i \in I: (u,i) \in S\}$$
$$U_i^+ \coloneqq \{u \in U: (u,i) \in S\}$$

由於整體的資料由所觀測到的隱性回饋 $S$、使用者負面回饋和缺失的資料所組成，過往的模型如 [[Matrix Factorization Model]] 僅針對使用者和物品的過往互動評分作為目標訓練，並且假設過往紀錄中負面回饋的使用者互動及缺失的互動紀錄評分皆為零分，由於並非所有未記錄的互動資訊皆
是使用者不喜歡的，因此將其評分定為零分是一個很強並且不利於推導階段使用的假設，這將讓模型對於未來的使用者物品互動 $(U \times I) \setminus S$ 傾向以零分訓練，因此為了使這樣的模型得以應用於預測未知的使用者互動，往往模型會加入避免過[[擬合]]的機制如[[正則化]]等。
與過往模型不同的是， BPR 將兩兩一組的一對物品作為訓練資料並且針對使用者對於物品的排序作為訓練目標，而非對於其中物品的評分。其假設在已觀測到的使用者互動中 $(u, i) \in S$ 使用者對於物品的排序是高於未互動到的物品的，因此對於一個使用者 $u_1$ 可以從該使用者的互動紀錄中取得 $>_{u_1}$ 使得 $i >_{u_1} j$ 其中 $i \in I_u^+$, $j \notin I_u^+$，也就是說當使用者 $u_1$ 有和 $i_1$ 互動過而沒有和 $i_2$ 互動過的情況下可以得知 $i_1 >_{u_1} i_2$，對於使用者都有互動過的兩物品或都沒有互動過的兩物品，在此假設下系統是無從得知其喜好的，因此實際上 BPR 會訓練到的資料集合 $D_S: U \times I \times I$ 如下：

$$
D_S \coloneqq \{(u, i, j)\ |\ i \in I_u^+ \land j \in I \setminus I_u^+\}
$$
意味著針對使用者 $u$ 其喜好 $i$ 勝過 $j$，並且由於反對稱性也考慮到了相反的配對。
這樣的目標設定有兩個好處：

1. 在此訓練中將訓練及和測試集做出了區分，而非是有所交集的。
2. 此種訓練的目標更加專注於排序勝過使用者物品間的評分數值。

### 訓練目標

