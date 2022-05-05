---
title: "PECOS"
date: 2022-05-06T02:09
---
## PECOS 是什麼
Prediction for Enormous and Correlated Output Space, PECOS 是 Amazon 於 2021 年提出的模型框架，用於解決 [[extreme multilabel ranking]] 問題。其善用標記資料 output Space 具有一定的相關性（correlation），透過 semantic indexing 分群和有效率的匹配最適合的 cluster 方法有效降低了 output space 龐大所導致的長尾問題。

## PECOS Model
PECOS 模型框架包含三個階段：
- Indexing Phase： PECOS 會將龐大的 labels 進行分群（semantic indexing），每一群都代表一個主題（Topic）。
- Matching Phase： PECOS 針對給定的 input instance 找尋其符合的主題。透過此部可以大幅下降 output space 的大小
- Rankiing Phase：在匹配到的主題當中對其中的 Label 基於其特徵以進行排序
![[Pasted image 20210930222612.png]]

在 indexing phase 和 matching phase 可以有效減少長尾效應所導致的資料稀疏問題。
## Product Retrieval
PECOS 模型應用於商品檢索時所使用的模型是 XR-Linear，此模型是基於 B-ary Tree，每個父節點的子節點數量最多為 B 個，因此第一層以下包含了所有的 label 而在下一層邊會將所有的 label 分為 B 個部分，依此類推。節點之間的邊是透過特徵計算機率分數來取權重，而在尋找最符合的 label 時會計算路徑機率最高的葉節點作為最終選定的 label，這個過程會透過 [[beam search]] 以提高效率。而另外也會透過設定 weight threshold 以進行修剪（weight pruning）。

針對 input query，有採用三種輸入：
	- n-grams of words：透過輸入片段字詞以增強模型針對連續字詞的判斷能力。
	- n-grams of characters：強化模型對錯別字或詞的變形處理能力。
	- TF-IDF：透過詞頻、常見字詞的統計，針對一定重要性的字詞進行判斷。
實驗結果中，同時採納三種輸入的方式效能是最好的。

## Session-aware query autocompletion

## Reference
- [Applying PECOS to product retrieval and text autocompletion](https://www.amazon.science/blog/applying-pecos-to-product-retrieval-and-text-autocompletion)
- [Amazon open-sources library for prediction over large output spaces](https://www.amazon.science/blog/amazon-open-sources-library-for-prediction-over-large-output-spaces)
- [Extreme multi-label learning for semantic matching in product search](https://www.amazon.science/publications/extreme-multi-label-learning-for-semantic-matching-in-product-search)
- [Session-aware query auto-completion using extreme multi-label ranking](https://www.amazon.science/publications/session-aware-query-auto-completion-using-extreme-multi-label-ranking)