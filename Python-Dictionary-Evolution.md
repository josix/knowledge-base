---
title: "Python-Dictionary-Evolution"
date: 2022-05-09T02:10
tags: python, hashmap
description: "Python 中處處是有 dictionary 使用的痕跡，如 `globals()`、`locals()`、modules、class、instances 皆是使用 dictionary 達成，因此其查找的效能是相當重要的，此文講述了 python 2.7 以來 dictionary 所做的效能改善，及其所使用的技巧..."
---
## Python Dictionary 的演進（until 3.6）

Python 中處處是有 dictionary 使用的痕跡，如 `globals()`、`locals()`、modules、class、instances 皆是使用 dictionary 達成，因此其查找的效能是相當重要的，此文講述了 python 2.7 以來 dictionary 所做的效能改善，及其所使用的技巧。

## Summary of the evolution
相較 python2.7 的 dictionary，python 3.5 中的 dictionary 引入 key sharing dictionary 節省了重複 key 所佔據的記憶體，dictionary 僅需執行一次 hash function 並另外儲存其對應的值。python 3.6 中將 dictionary 再進行了壓縮，進而節省更多的記憶體。除了記憶體使用大小外，python 2.7 的 dictionary 每次輸出的順序是固定的，但卻是基於 hash function 所決定，而 python 3.5 中的  dictionary 的輸出順序會是隨機的直到 3.6 其順序會是固定的。

## The Evolution
以一個 key 為人名、value 為 color、city、fruits 的 dictionary 為例，最簡易的 mapping table 是一張列出了所有 key 和 value 欄位的表：
```python
# Name Color City Fruit
# -------- -------- --------- -------
# 'guido', 'blue', 'austin', 'apple'
# 'sarah', 'orange', 'dallas', 'banana'
# 'barry', 'green', 'tuscon', 'orange'
# 'rachel', 'yellow', 'reno', 'pear'
# 'tim', 'red', 'portland', 'peach'

# implemented as follow, a list of tuple
[('guido', 'blue', 'austin', 'apple'),
('sarah', 'orange', 'dallas', 'banana'),
('barry', 'green', 'tuscon', 'orange'),
('rachel', 'yellow', 'reno', 'pear'),
('tim', 'red', 'portland', 'peach')]
```

在查找時，會需要進行 linear search，這種資料結構的缺點是隨著存放的項目增加時這將讓搜尋的效能線性成長。稍微改善的方式是針對不同的欄位分別存放在不同的 list，針對不同的欄位在不同的 list 進行線性查找，而這將重複存放相同的 key，進而增加了所需的記憶體：
```python
[
  [
   ('guido', 'blue'),
   ('sarah', 'orange'),
   ('barry', 'green'),
   ('rachel', 'yellow'),
   ('tim', 'red')
  ],
  [
   ('guido', 'austin'),
   ('sarah', 'dallas'),
   ('barry', 'tuscon'),
   ('rachel', 'reno'),
   ('tim', 'portland')
  ],
  [
   ('guido', 'apple'),
   ('sarah', 'banana'),
   ('barry', 'orange'),
   ('rachel', 'pear'),
   ('tim', 'peach') 
  ],
]
```
### Separate Chaining
相較在一個 list 上進行查找，我們可以將其拆分成多個小的 list，進而減少每個 list 線性查找的長度。我們稱放置這些小 list 的位置為 bucket，bucket 的核心意義在於縮小要搜尋的範圍，拆成 N 個小的 list 並在這些 list 中查找。而如何設定項目要放置的 bucket 位置只需要透過  [[hash function]] 將一個 key 轉換為一個數字將其除以 bucket 取餘數即可。例如使用 2 個 bucket 的 separate chaining ， `guido` 和 `tim` 經過 hash 後得到的位置是第一個 bucket，其餘為第二個 bucket，如下：
```python
[[('guido', 'blue'), ('tim', 'red')],
[('sarah', 'orange'), ('barry', 'green'), ('rachel', 'yellow')]]
```
原先需要最糟情況下需要查找次數為五次，在這個資料結構下只需要計算一次 hash  再查詢三次即可。

> 實作上經常將 bucket 數量設定為 2 的 n 次方個數，這將讓取餘數計算更加方便，只需要針對該數字尾數的 n 個 bits 即可以取得其餘數數值。

而隨著這定 bucket 的數量增加，因為可以存放同的 bucket 變多 ，每個 bucket 所包含的項目數量減少，其最糟情況下的線性查找長度便會減少，例如設定 8 個 bucket 的 separate chaining 如下:
```python
[[],
[('barry', 'green')],
[('sarah', 'orange')],
[],
[],
[('guido', 'blue'), ('rachel', 'yellow')],
[],
[('tim', 'red')]]
```
使用 hash function 決定 bucket 的位置，是有可能找到相同的位置的，這又稱為碰撞（ collision ），每發生碰撞即代表該項目查找所需的時間比較長一些。
這個方法犧牲了空間換取查找的效率，然而可以發現兩個可以改善的地方：
- 隨著存放的項目增加，每個 bucket 都有存放的情況下，各個 list 的長度便會慢慢增加，查找的效能便會越來越差，以 8 個 bucket 例子來說，若總共有 2000 項目需要存放則平均每個 list 會被放 250 個項目。為了解決這個問題，於是有了 Dynamic Resizing 的技巧。
- 存放在不同的 list 在沒有使用完原先配置的記憶體前配置了額外更多的記憶體，這將浪費記憶體的用量，並且也不立於 memory cache。

### Dynamic Resizing
針對上述第二點，面對的問題是如何避免放過多的項目到每個 bucket 當中，Dynamic Resizing 透過每當 dictionary 進行 insertion 時會檢查自身的 load factor （項目數量 / bucket 數量），超過 2/3 時會依照設定的 `GROWTH_RATE` 重新配置一個更大的 dictionary ，有了更大的 dictionary 項目便減少了被放置在同一個 bucket 的機會，因此效能便不會降低。
> GROWTH_RATE 的設定：
 Python 3.4.0 - 3.6.0 設定新配置的 dict 大小*為已使用大小 \* 2 + 已配置大小 /2*)
> Python 3.6.0 - 3.8.0 設定為*已使用大小 \* 3*
### Caching the Hash Value
與教科書所教授不同的是，實作上除了將 key, value 放入 hashtable 以外，也會將 hash value 也一併存入：
```python
[[],
[(873286367057653889, 'barry', 'green')],
[(1395608851306079410, 'sarah', 'orange')],
[],
[],
[(2612508993932319405, 'guido', 'blue'),
(8886176438393677637, 'rachel', 'yellow')],
[],
[(38617469636359399, 'tim', 'red')]]
```
這麼做的好處是，當面臨 hashmap resizing，若將每個 key 都重新再計算一次 hash 是會很花時間的，因此， Python dictionary 的實作選擇犧牲更多的空間將以計算過的 hash value cache 存放至 hashtable 中，因此在 resizing 階段便可以跳過計算 hash value 的階段，直接計算 `hashvalue % n_bucket` 取得要存放的位置，將可以提升許多速度。
```Python
def faster_resize(self, n):
    new_buckets = [[] for i in range(n)] # Make a new, bigger table
    for hashvalue, key, value in self.buckets: # Re-insert the saved pairs
        bucket = new_bucket[hashvalue % n] # Re-use cached hash value
        bucket.append((hashvalue, key, value))
```
### Faster Matching
而在查找階段，dictionary 需要檢視是否 `key == target_key` 以找到存放的項目，然而由於 Python Data Model Protocol，其內部呼叫 `__eq__` 方法會隨著物件的複雜度而有越來越多的計算量，因此 python dictionary 採用了兩個 early-out 的作法進行加速避免計算 `__eq__` ：
- 倘若兩個變數指向的物件其所放置的記憶體位置相同，那麼該兩物件為同一個物件，也就是 `identity immplies equality` ，也就是說，在判斷時可以直接判定其 `id(object)`  是否相同，若相同，則必是同一個物件。
- 若兩個物件相同則其 hash value 會相同，其反面論述也會成立，若兩個 hash value 不同，則可以代表這兩個物件不同。需要注意的是即便 hash key 相同也不一定代表是同一個物件，依照 hash function 的不同，依然有可能是相同的 hash value。
```python
def fast_match(key, target_key):
    if key is target_key: return True # Fast
    if key.hash != target_key.hash: return False # Fast
    return key == target_key # Slow
```

### Open Addressing
針對 Separating Chaining 的第一個問題，碰撞所產生的 list 會花費額外的記憶體用量，Open Addressing 透過將所有 list 中的項目都放回原先配置 table 的位置中，讓 hashmap 使用率更加密集，針對碰撞的問題透過 linear probing，找尋碰撞的下一個位置是否是空的，直到找到空的並放入項目。
```python
def open_addressing_linear(n):
    table = [None] * n
    for h, key, value in entries:
        i = h % n
        while table[i] is not None:
            i = (i + 1) % n
        table[i] = (key, value)
```
```python
[('tim', 'red'), # 'tim' collided with 'sarah'
None,
None,
('guido', 'blue'),
('rachel', 'yellow'),
None,
('barry', 'green'),
('sarah', 'orange')]
```

#### Deleted Entry

使用 Open Addressing 有一個缺點在於當有項目被刪除時，與該項目有產生過碰撞的所有項目就會失去找到其位置的途徑，如上範例，當 `sarah` 被刪除的話，會被視為是空的因此當要找尋 `tim` 時，反而會找到過去原本是 `sarah` 的空位置，並返回新加入項目或是回覆沒有 `tim` 這個項目。因此解決的辦法為新增一個 DUMMY 項目狀態表示該位置曾經有值並已刪除，找尋到此位置時需要繼續向下個位置探查，而非如同找尋到空的位置視為已經找完。

Python 目前以 Knuth Algorithm D 達成查找，標註 DUMMY 項目將可以有像再次利用該位置放置新加入的項目，然而 DUMMY 項目也會算入 load factor 中，因此 load factor 會被高估而提早進行 resizing。
```python
def lookup(h, key):
    freeslot = None # No dummy encountered yet
    for h, key, value in entries:
        i = h % n
        while True:
            entry = table[i]
            if entry == FREE:
                return entry if freeslot is None else freeslot
            elif entry == DUMMY:
                if freeslot is None:
                    freeslot = i # Remember where the dummy is
            elif fast_match(key, entry.key):
                return entry
            i = (i + 1) % n
```

#### Multiple Hashing

為了避免 linear probing 的查找/加入項目的方式容易導致項目堆疊於鄰近的位置，隨著數量增加、碰撞的次數增加將會讓查找的效能降低，因此需要有更好的方式平均分散放置項目於 hashmap 當中，常見的作法有將 linear probing 改成使用 quadratic probing、robin-hood hasing 等，增加查找的速度或是避免過久的查找。而 python 使用的方式是考慮 hash value 中位元數高的數值重新 hash 再透過線性同餘產生亂數公式（$i = 5 * i + 1$）找到下一個要放置的位置，該公式需證明會遍歷所有的位置。而考慮到高位元的 hash value 又被稱為 perturb，應用於亂數產生公式為（$i = 5*i + perturb + 1$）實際的演算法如下：
```python
def open_addressing_multihash(n):
    table = [None] * n
    for h, key, value in entries:
        perturb = h
        i = h % n
        while table[i] is not None:
            i = (5 * i + perturb + 1) % n
            perturb >>= 5
            table[i] = (h, key, value)
```
`open_addressing_multihash(8)` 執行的結果如下：
```python
'barry' collided with 'guido'
'rachel' collided with 'guido'
'rachel' collided with 'barry'
'rachel' collided with 'guido'
'tim' collided with 'rachel'
[(2612508993932319405, 'guido', 'blue'),
(873286367057653889, 'barry', 'green'),
None,
(1395608851306079410, 'sarah', 'orange'),
None,
(8886176438393677637, 'rachel', 'yellow'),
None,
(38617469636359399, 'tim', 'red')]
```
### Early-Out for Lookups

由於 python 中的 global namespace, instance namespace, builtin namespace 經常會使用到 Dict 查找，因此 Victor Stinner 提出了 PEP 509 - Add a private version to dict，為每個 Dict 加入 version 版本，以版本鑒察作為 guard，每當調用 class method 或是 function 時，真要向 guard 確認是否 dict 有所改變，若沒有的話，可以加速其調用的速度，反之使用一般的 lookup 調用。

### Compact Dict

不論是 Open Addressing 或是 Saperating Chaining 的 hashmap 實作方式，都不可避免存在著空的位置沒有被使用到。因此為了更有效的使用空間，Raymond Hettinger 將所有存放的內容如 hash value、keys、items 都另外存放於獨立出來的 list 中，並且在原本的 hashmap 中存放對應的 index，以便查找。
```python
[(6364898718648353932, 'guido', 'blue'),
(8146850377148353162, 'sarah', 'orange'),
(3730114606205358136, 'barry', 'green'),
(5787227010730992086, 'rachel', 'yellow'),
(4052556540843850702, 'tim', 'red')]

[2, None, 1, None, 0, 4, 3, None]
```

### Key-Sharing Dict

隨著 Dictionary 的數量越多，若許多 dictionary 的 key 重複的數量越多，原本的設計會重複紀錄 hash value、key value、item value，因此 Mark Shannon 在 `PEP412 - Key-Sharing Dictionary` 中提出將這些重複的內容另外存放：
```python
def shared_and_compact(n):
    'Compact, ordered, and shared'
    table = [None] * n
    for pos, entry in enumerate(comb_entries):
        h = perturb = entry[0]
        i = h % n
        while table[i] is not None:
            i = (5 * i + perturb + 1) % n
            perturb >>= 5
        table[i] = pos
    pprint(comb_entries)
    pprint(table)
```
`shared_and_compact(8)` 執行的結果如下：
```python
[(6677572791034679612, 'guido', 'blue', 'austin', 'apple'),
(47390428681895070, 'sarah', 'orange', 'dallas', 'banana'),
(2331978697662116749, 'barry', 'green', 'tuscon', 'orange'),
(8526267319998534994, 'rachel', 'yellow', 'reno', 'pear'),
(8496579755646384579, 'tim', 'red', 'portland', 'peach')]

[None, None, 3, 4, 0, 2, 1, None]
```

## Reference

- [Modern Dictionaries - Raymond Hettinger](https://www.youtube.com/watch?v=p33CVV29OG8)
- [High Efficient Python](https://www.oreilly.com/library/view/high-performance-python/9781492055013/)
- [PEP509-Add a private version to dict](https://peps.python.org/pep-0509/)