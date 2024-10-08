---
title: "Transaction"
date: 2023-02-14T15:49
dg-publish: true
dg-permalink: "software-engineer/designing-data-intensive-application/transaction"
tags: database, transaction
description: "Transaction 是資料庫執行邏輯上單一不可切割的執行單位，其中包含了多個讀取、寫入的行為。在 transaction 中執行的所有讀取和寫入，其概念上會被視為是單獨的執行行為，其結果只有全部成功（commit）或是失敗（abort, rollback）。"
---
<!-- # 筆記本體 -->

Transaction 是資料庫執行邏輯上單一不可切割的執行單位，其中包含了多個讀取、寫入的行為。在 transaction 中執行的所有讀取和寫入，其概念上會被視為是單獨的執行行為，其結果只有全部成功（commit）或是失敗（abort, rollback）。

Transaction 帶來的好處在於排除了部分失敗的情境，資料庫的錯誤處理將會簡單並且容易許多，在於 concurrency 的使用情境下開發人員也省去判斷發生錯誤的可能性，因為資料庫具有ㄧ定的安全性保證（safety guarantees）。

## ACID
對於資料庫提供的安全性保證（safety guarantees）我們通常視其包含四個特性，其各方面達到的程度依照每個資料庫實作細節亦有所不同：

- 原子性（Atomicity）：原子性保證 transaction 執行的最小單位，在多個更動之中只要有任何錯誤發生，該 transaction 即會被捨棄（abort）因此開發者不需要去考慮部份錯誤的情況，不會因為部份錯誤而引發資料重複、或重複更動的問題。
- ㄧ致性（Consistency）：一致性保證經過一系列 transaction 更動後資料庫中的資料需要保持一致的狀態，如假設 A 帳戶中有 1000 元，當 A 向 B 轉移100元時，系統必須保證 A 的帳戶餘額減少 100 元，而 B 的帳戶餘額增加 100 元。
- 隔離性（Isolation）：隔離性又可以被稱為可序列化性（serializability），每個 transaction 可以視為是獨立互不影響的，意味著在 concurrent 的情境下，transaction 執行的順序並不會影響資料最終存放於資料庫的結果。
- 持久性（Durability）：持久性意味著每當 transaction 成功完成時，寫入的資料將可以預期其永遠存在於資料庫當中，即便發生硬體故障或是資料庫崩潰，我們都可以在未來恢復正常時得到過去寫入的資料。在單一節點的情況下，持久性代表著資料庫要將資料寫入非揮發記憶體如 HDD，SSD 等，然而在分散式系統中，意味著每一次資料的寫入會經過 [[Replication]]，將資料備份在其他機器上，才能夠告訴使用者該筆資料寫入完成。

### Single-Object Transactions vs Multi-Object Transactions

Multi-object transaction 指的是當一次 transaction 會更動到多個物件（rows, documents, records）時的運作，反之只影響到單一物件的情況則稱為 single-object transaction，在 multi-object transaction 的使用情境下，資料庫需要確保不同物件之間的隔離性和一致性，若執行失敗則需要依照原子性，將該 transaction 捨棄。而在 single-object transaction 的情境下，需要確認單一物件內的欄位更動符合一致性和隔離性（透過對每個物件上 lock 以確保只有一個執行緒可以對該物件進行更動），為了更貼合原子性，資料庫有時會提供 increment 運算而不用進行 read-modify-write 的執行週期，或是 [[compare-and-set （CAS）]]運算允許寫入在 concurrey 情況下通過比較預期值是否等於當前實際值來實現任一執行緒對資料的更新。



<!-- 
## 延伸問題
## See Also
-->
## References
- Designing Data Intensive Application - Chapter 7 Transactions