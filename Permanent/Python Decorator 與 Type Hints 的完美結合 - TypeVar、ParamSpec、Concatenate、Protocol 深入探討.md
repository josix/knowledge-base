---
date: 2025-10-17T06:40:06.533Z
description: 在 Python 開發中，當我們嘗試為 decorator 加上型別標註時，經常會遇到型別檢查器無法正確推斷函式簽名的問題。這篇文章將深入探討如何使用 TypeVar、ParamSpec、Concatenate 和 Protocol 等進階型別功能，來讓 decorator 也能擁有完整的型別安全。
---

# Python Decorator 與 Type Hints 的完美結合 - TypeVar、ParamSpec、Concatenate、Protocol 深入探討

## 為什麼需要為 Decorator 加上 Type Hints

為 Python decorator 加上型別標註時，最常遇到的問題是：型別檢查器無法正確推斷被裝飾函式的簽名，導致 IDE 失去自動補全能力，也無法在編譯時期捕捉型別錯誤。本文將介紹如何使用 Python 的進階型別功能 TypeVar、ParamSpec、Concatenate 和 Protocol，讓 decorator 也能擁有完整的型別安全，不再需要到處加上 `# type: ignore` 註解。

以一個簡單的計時 decorator 為例：

```python
import time
from functools import wraps

def timer(func):
    """測量函式執行時間的裝飾器"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} 花費 {elapsed:.2f}s")
        return result
    return wrapper
```

這個 decorator 在執行時期完全沒問題，可以裝飾任何函式：

```python
@timer
def process_data(data: list[int], threshold: int = 10) -> list[int]:
    """處理超過閾值的資料"""
    return [x for x in data if x > threshold]

# 執行時期：正常運作
result = process_data([1, 5, 15, 20], threshold=10)
# 輸出： process_data 花費 0.00s
```

但是當你啟用型別檢查工具如 mypy 或 pyright 時，會發現問題：

```python
result = process_data([1, 5, 15, 20], threshold=10)
# result 的型別：Any (而不是 list[int])

# 更糟的是，型別檢查器無法捕捉這些錯誤：
process_data("invalid", threshold="wrong")  # 應該要報錯，但沒有警告
process_data()  # 應該要報錯，但沒有警告
```

**為什麼會這樣？** 因為 decorator 回傳的 `wrapper` 函式接受 `*args, **kwargs`，型別檢查器無法得知這個 wrapper 應該要有與原始函式相同的簽名。從型別檢查器的角度來看，`process_data` 變成了一個接受任意參數並回傳 `Any`（或 Unknown／未知型別，依檢查器設定）的函式。這導致型別檢查器無法驗證函式呼叫的正確性。

在大型程式庫中，這會有下列的問題：

- IDE 無法提供準確的自動補全和 tooltips 表示正確的簽名
- 重構變得危險（無法透過 IDE 可靠地找到所有呼叫位置）
- 應該在靜態型別檢查時捕捉的型別錯誤會延遲到執行時期
- 文件與程式碼分離，除非閱讀程式碼或文件，否則無法知道函式的正確使用方式

而這問題就在於：**如何在保持 decorator 靈活性的同時維持型別安全？**

這正是 Python 進階型別功能所要解決的問題。接下來，我們將探討 `TypeVar`、`ParamSpec`、`Concatenate` 和 `Protocol`，了解它們不只是如何使用，更重要的是為什麼需要它們以及它們解決了什麼問題。

## TypeVar：建立型別之間的關聯

### 核心概念

在理解 `ParamSpec` 和 `Concatenate` 之前，我們需要先深入理解 `TypeVar`。它是所有進階型別功能的基礎。

以這個函式為例：

```python
def get_first_item(items: list) -> object:
    """取得列表的第一個項目"""
    return items[0]
```

這在執行時期可以運作，但看看型別會發生什麼事：

```python
numbers = [1, 2, 3]
first = get_first_item(numbers)  # 型別: object
result = first + 1  # 型別錯誤! 無法將 object 和 int 相加
```

我們知道如果傳入整數，就會得到整數，但這卻難以在 Type Hint 系統中表達這種關係。

這正是 `TypeVar` 要解決的問題：

```python
from typing import TypeVar

T = TypeVar("T")

def get_first_item(items: list[T]) -> T:
    """取得列表的第一個項目"""
    return items[0]

numbers: list[int] = [1, 2, 3]
first: int = get_first_item(numbers)  # 型別: int!
result = first + 1  # ✓ 型別檢查器滿意了
```

### 運作原理

關鍵的理解是：**TypeVar 建立了型別之間的關聯**。當你寫 `list[T] -> T` 時，你是在告訴型別檢查器：「無論輸入的 `T` 是什麼型別，輸出的 `T` 就是完全相同的型別。」

型別檢查器會在每個呼叫位置執行型別推論：

```python
get_first_item([1, 2, 3])      # T = int，回傳 int
get_first_item(["a", "b"])     # T = str，回傳 str
get_first_item([[1], [2]])     # T = list[int]，回傳 list[int]
```

每個呼叫位置都會獨立分析，型別檢查器根據實際參數推導出 `T` 的型別。

### 在 Decorator 中使用 TypeVar

現在讓我們將這個概念應用到 decorator 上。這是計時 decorator 的第一次改善：

```python
import time
from functools import wraps
from collections.abc import Callable
from typing import TypeVar

T = TypeVar("T")

def timer(func: Callable[..., T]) -> Callable[..., T]:
    """保留回傳型別的計時裝飾器"""
    @wraps(func)
    def wrapper(*args, **kwargs) -> T:
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} 花費 {elapsed:.2f}s")
        return result
    return wrapper

@timer
def process_data(data: list[int], threshold: int = 10) -> list[int]:
    return [x for x in data if x > threshold]

result = process_data([1, 5, 15, 20], threshold=10)
# 型別檢查器現在知道： result 是 list[int]!
```

這是一個顯著的改善，回傳型別現在能夠流經 decorator，但注意我們參數仍然用 `...`，這表示「此函式接受任意參數」。

```python
# 型別檢查器仍然不會報錯：
process_data("invalid", threshold="wrong")
```

這就引出了下一個層次：`ParamSpec`。

### Bounded TypeVar：重要的模式

在繼續之前，還有一個關於 `TypeVar` 的重要概念，對於方法裝飾器來說很關鍵：**有界型別變數 （bounded type variable）**。

以下列情境來說：

```python
class Animal:
    def speak(self) -> str:
        return "某種聲音"

class Dog(Animal):
    def speak(self) -> str:
        return "汪汪"

    def fetch(self) -> None:
        print("正在撿球")

def announce(animal: Animal) -> Animal:
    """宣告動物"""
    print(f"動物說: {animal.speak()}")
    return animal

my_dog = Dog()
returned_dog = announce(my_dog)
# returned_dog 的型別： Animal (不是 Dog!)
returned_dog.fetch()  # 型別錯誤： Animal 沒有 fetch 方法
```

即使我們傳入了 `Dog`，我們得到的是 `Animal`。型別檢查器不知道輸出型別與輸入型別相符。對於類別方法的裝飾器來說，這是特別容易出現的問題。

解決方案是**有界 TypeVar**：

```python
AnimalT = TypeVar("AnimalT", bound=Animal)

def announce(animal: AnimalT) -> AnimalT:
    """宣告動物，保留其特定型別"""
    print(f"動物說: {animal.speak()}")
    return animal

my_dog = Dog()
returned_dog = announce(my_dog)
# returned_dog 的型別: Dog!
returned_dog.fetch()  # ✓ 型別檢查器知道 Dog 可以 fetch
```

**`bound=Animal` 的意義**：「`AnimalT` 可以是 `Animal` 或 `Animal` 的任何子類別」。bound 確保：

1. 型別檢查器知道某些方法存在(如 `speak()`)
2. 特定子類別的型別會在函式中保留

這在裝飾方法時變得很重要，我們稍後會看到。

## ParamSpec：保留函式簽名

### TypeVar 的限制

讓我們重新審視使用 `TypeVar` 的計時 decorator：

```python
T = TypeVar("T")

def timer(func: Callable[..., T]) -> Callable[..., T]:
    def wrapper(*args, **kwargs) -> T:
        # ...
    return wrapper
```

我們保留了回傳型別，但 `...` 表示「未知參數」。型別檢查器無法驗證：

- 函式接受多少參數
- 這些參數應該是什麼型別
- 哪些參數是必要的、哪些是可選的
- 是否允許關鍵字參數

### ParamSpec 登場

`ParamSpec` 在 Python 3.10 引入，專門用來解決這個問題。可以這樣理解他們的角色：

- **TypeVar** 捕捉一個**型別**(如 `int` 或 `list[str]`)
- **ParamSpec** 捕捉一個**參數列表**(如 `(x: int, y: int)` 或 `(name: str, age: int = 0)`)

使用方式如下：

```python
import time
from functools import wraps
from collections.abc import Callable
from typing import TypeVar, ParamSpec

P = ParamSpec("P")
T = TypeVar("T")

def timer(func: Callable[P, T]) -> Callable[P, T]:
    """完整保留簽名的計時裝飾器"""
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} 花費 {elapsed:.2f}s")
        return result
    return wrapper
```

關鍵部分是：

- `Callable[P, T]` - 「一個參數為 P、回傳型別為 T 的函式」
- `*args: P.args` - 「符合 P 的位置參數」
- `**kwargs: P.kwargs` - 「符合 P 的關鍵字參數」

### ParamSpec 的運作方式

當你裝飾一個函式時，型別檢查器會捕捉其完整簽名：

```python
@timer
def process_data(data: list[int], threshold: int = 10) -> list[int]:
    return [x for x in data if x > threshold]

# 型別檢查器捕捉:
# P = (data: list[int], threshold: int = 10)
# T = list[int]

# 現在它可以驗證所有這些:
process_data([1, 2, 3], threshold=5)           # ✓ 正確
process_data([1, 2, 3])                        # ✓ threshold 是可選的
process_data([1, 2, 3], 5)                     # ✓ 位置參數可行
process_data(data=[1, 2, 3], threshold=5)      # ✓ 關鍵字參數可行

# 並捕捉所有這些錯誤:
process_data()                                 # ✗ 缺少必要參數
process_data("invalid")                        # ✗ 錯誤的型別
process_data([1, 2, 3], threshold="wrong")     # ✗ threshold 型別錯誤
process_data([1, 2, 3], 5, "extra")            # ✗ 參數過多
```

函式簽名的每個面向都被保留並驗證。

### 為什麼 ParamSpec 很重要

這樣的型別安全確認是相當重要的，特別是在大型程式庫中。我們經常會重構函式簽名，並且希望型別檢查器能幫助我們找到所有受影響的呼叫位置。

舉例來說，我有一個快取 decorator 用在整個程式庫的數十個函式上：

```python
@cache(ttl=300)
def fetch_user_data(user_id: int, include_details: bool = False) -> dict:
    # 昂貴的資料庫呼叫
    pass
```

隨著時間演進，我們重構了函式簽名：

```python
@cache(ttl=300)
def fetch_user_data(user_id: str, include_details: bool = False) -> dict:
    # 將 user_id 從 int 改為 str
    pass
```

有了快取 decorator 上正確的 `ParamSpec` 型別，型別檢查器立即標記出 23 個傳入整數而非字串的呼叫位置。如果沒有它，這些將會是生產環境的執行時期錯誤。

這就是 ParamSpec 存在的原因：**讓 decorator 與它們裝飾的函式一樣型別安全**。

## Concatenate：組合參數列表

### 下一個挑戰

`ParamSpec` 解決了簽名保留的問題，但它引入了一個新問題。如果你的 decorator 需要修改簽名怎麼辦？

看看這個常見模式 - 為函式注入 context：

```python
P = ParamSpec("P")
T = TypeVar("T")

def with_context(func: Callable[P, T]) -> Callable[???, T]:
    def wrapper(???) -> T:
        # 我們想要注入一個 Context 參數
        # 但如何標註型別?
        pass
    return wrapper
```

或是方法裝飾器：

```python
def method_decorator(func: Callable[P, T]) -> Callable[P, T]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
        # 對於方法，args[0] 是 self
        # 但如何特別標註 self 的型別?
        pass
    return wrapper
```

這就是 `Concatenate` 的用途。

### 理解 Concatenate

`Concatenate` 讓你可以說：「參數是這些特定型別，後面跟著 `P` 捕捉的任何內容。」

語法是：`Concatenate[FixedType1, FixedType2, P]`

讓我們看看實際應用：

```python
import time
from functools import wraps
from collections.abc import Callable
from typing import Concatenate, ParamSpec, TypeVar

P = ParamSpec("P")
T = TypeVar("T")

def with_logging(
    func: Callable[Concatenate[str, P], T]
) -> Callable[P, T]:
    """注入日誌前綴作為第一個參數"""
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
        log_prefix = f"[{time.strftime('%H:%M:%S')}]"
        return func(log_prefix, *args, **kwargs)
    return wrapper

@with_logging
def process_item(log_prefix: str, item_id: int, validate: bool = True) -> dict:
    """處理項目，自動注入日誌前綴"""
    print(f"{log_prefix} 處理項目 {item_id}")
    return {"id": item_id, "processed": True}

# 呼叫者不需提供 log_prefix - 它會被注入:
result = process_item(item_id=123, validate=False)
# ✓ 型別檢查器知道：result 是 dict
# ✓ 型別檢查器驗證：item_id 必須是 int， validate 必須是 bool
```

### 分解型別

讓我們仔細分析發生了什麼：

```python
def with_logging(
    func: Callable[Concatenate[str, P], T]
) -> Callable[P, T]:
```

**輸入**：`Callable[Concatenate[str, P], T]`

- 被裝飾的函式必須接受 `str` 作為第一個參數
- 後面跟著 `P` 捕捉的任何參數
- 回傳型別 `T`

**輸出**：`Callable[P, T]`

- 回傳的 wrapper 接受參數 `P`（沒有 `str` 前綴）
- 回傳型別 `T`

**decorator 轉換**：`(str, *P) -> T` 變成 `(*P) -> T`

對於我們的 `process_item` 範例：
- 原始簽名：`(log_prefix: str, item_id: int, validate: bool = True) -> dict`
- P 捕捉：`(item_id: int, validate: bool = True)`
- Wrapper 簽名：`(item_id: int, validate: bool = True) -> dict`

從呼叫者的角度來看，`log_prefix` 參數消失了，因為 decorator 提供了它。

### 方法裝飾器：最常見的使用案例

`Concatenate` 最常見的用途是方法裝飾器，當你裝飾實例方法時，`self` 會被隱式傳遞：

```python
class DataProcessor:
    def process(self, data: list[int]) -> int:
        return sum(data)

processor = DataProcessor()
processor.process([1, 2, 3])  # self 被隱式傳遞
```

對於方法裝飾器，我們想要：

1. 明確標註 `self` 的型別（這樣我們可以存取它的屬性）
2. 用 `ParamSpec` 捕捉剩餘的參數

```python
import time
from functools import wraps
from collections.abc import Callable
from typing import Concatenate, ParamSpec, TypeVar

P = ParamSpec("P")
T = TypeVar("T")
SelfT = TypeVar("SelfT")

def timing_decorator(
    func: Callable[Concatenate[SelfT, P], T]
) -> Callable[Concatenate[SelfT, P], T]:
    """用於計時實例方法的裝飾器"""
    @wraps(func)
    def wrapper(self: SelfT, *args: P.args, **kwargs: P.kwargs) -> T:
        start = time.time()
        result = func(self, *args, **kwargs)
        elapsed = time.time() - start
        print(f"{self.__class__.__name__}.{func.__name__} 花費 {elapsed:.2f}s")
        return result
    return wrapper

class DataProcessor:
    @timing_decorator
    def process_batch(self, items: list[int], batch_size: int = 10) -> list[int]:
        """批次處理項目"""
        # 實作
        return items

processor = DataProcessor()
result = processor.process_batch([1, 2, 3], batch_size=5)
# ✓ 型別檢查器驗證: items 是 list[int]， batch_size 是 int
# ✓ 型別檢查器知道: result 是 list[int]
```

**發生了什麼**：

- `Concatenate[SelfT, P]` 意思是「型別為 `SelfT` 的 `self`，後面跟著參數 P」
- 對於 `process_batch(self, items: list[int], batch_size: int = 10)`：
  - 第一個參數（`self`）是 `SelfT`
  - P 捕捉：`(items: list[int], batch_size: int = 10)`

> Concatenate 只能在 Callable[Concatenate[..., P], R] 的參數位置使用，而且不支援「插入 / 重新定義僅限關鍵字參數」這類情境；為[PEP 612](https://peps.python.org/pep-0612/#concatenating-keyword-parameters) 已知限制。

### 進階：Context 注入模式

常見使用 `Concatenate` 的模式之一是用於 Web API 的 context 注入：

```python
from dataclasses import dataclass
from functools import wraps
from collections.abc import Callable
from typing import Concatenate, ParamSpec, TypeVar

@dataclass
class RequestContext:
    user_id: str
    request_id: str
    trace_id: str

P = ParamSpec("P")
R = TypeVar("R")

def with_request_context(
    func: Callable[Concatenate[RequestContext, P], R]
) -> Callable[P, R]:
    """從 thread-local storage 注入請求 context"""
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        # 從 thread-local、請求標頭等取得 context
        ctx = RequestContext(
            user_id=get_current_user_id(),
            request_id=get_request_id(),
            trace_id=get_trace_id()
        )
        return func(ctx, *args, **kwargs)
    return wrapper

@with_request_context
def get_user_orders(
    ctx: RequestContext,  # 自動注入!
    user_id: int,
    limit: int = 10
) -> list[dict]:
    """取得使用者的訂單"""
    # 可以使用 ctx 進行日誌記錄、追蹤等
    print(f"請求 {ctx.request_id} 正在為使用者 {user_id} 取得訂單")
    return fetch_orders(user_id, limit)

# 呼叫者不需提供 context:
orders = get_user_orders(user_id=123, limit=5)
```

這個模式非常方便，因為

1. 業務邏輯明確宣告它需要 context（透過參數）
2. 呼叫者不需要提供它（decorator 處理）
3. 所有東西都是完全型別檢查的
4. 測試很容易（可以明確傳遞 context）

## Protocol：結構型別

### 最後一塊拼圖

我們已經介紹了如何保留函式簽名（`ParamSpec`）和組合參數列表（`Concatenate`）。但還有一個挑戰：**如何指定 `self` 必須有某些屬性？**

讓我們看一個具體例子：

```python
T = TypeVar("T")
P = ParamSpec("P")

def log_errors(func: Callable[Concatenate[T, P], None]) -> Callable[Concatenate[T, P], None]:
    def wrapper(self: T, *args: P.args, **kwargs: P.kwargs) -> None:
        try:
            func(self, *args, **kwargs)
        except Exception as e:
            self.logger.error(f"錯誤: {e}")  # ✗ 型別錯誤: T 沒有屬性 logger!
            raise
    return wrapper
```

型別檢查器會抱怨，因為 `T` 是無界的，它可以是任何型別，我們無法安全地存取 `self.logger`。

### 第一次嘗試：使用基礎類別的有界 TypeVar

你可能會想：「用基礎類別就好」

```python
import logging
from functools import wraps
from collections.abc import Callable
from typing import Concatenate, ParamSpec, TypeVar

class BaseService:
    logger: logging.Logger

T = TypeVar("T", bound=BaseService)
P = ParamSpec("P")

def log_errors(func: Callable[Concatenate[T, P], None]) -> Callable[Concatenate[T, P], None]:
    @wraps(func)
    def wrapper(self: T, *args: P.args, **kwargs: P.kwargs) -> None:
        try:
            func(self, *args, **kwargs)
        except Exception as e:
            self.logger.error(f"{func.__name__} 發生錯誤: {e}") # ✓ 現在可行了
            raise
    return wrapper

class UserService(BaseService):  # 必須繼承!
    def __init__(self):
        self.logger = logging.getLogger("UserService")

    @log_errors
    def create_user(self, email: str) -> None:
        # 實作
        pass
```

這可行，但有一個顯著的限制：**每個類別都必須繼承自 `BaseService`**，不過也帶來了一些缺點：

- 建立了緊密耦合
- 防止在現有類別上使用 decorator 而不需重構
- 違反了組合優於繼承的原則
- 讓測試變得更困難

### Protocol：結構型別的救星

`Protocol` 為 Python 引入了結構型別，不是問「這個物件是 BaseService 嗎?」，而是問「這個物件有我們需要的屬性/方法嗎?」

```python
import logging
from functools import wraps
from collections.abc import Callable
from typing import Concatenate, ParamSpec, Protocol, TypeVar

class HasLogger(Protocol):
    """具有 logger 屬性的物件的協定"""
    logger: logging.Logger

T = TypeVar("T", bound=HasLogger)
P = ParamSpec("P")

def log_errors(
    func: Callable[Concatenate[T, P], None]
) -> Callable[Concatenate[T, P], None]:
    """用於有 logger 屬性的類別方法的裝飾器"""
    @wraps(func)
    def wrapper(self: T, *args: P.args, **kwargs: P.kwargs) -> None:
        try:
            func(self, *args, **kwargs)
        except Exception as e:
            self.logger.error(f"{func.__name__} 發生錯誤: {e}")
            raise
    return wrapper

# 不需要繼承!
class UserService:
    def __init__(self):
        self.logger = logging.getLogger("UserService")

    @log_errors
    def create_user(self, email: str) -> None:
        if "@" not in email:
            raise ValueError(f"無效的電子郵件: {email}")
        # 實作

class OrderService:
    def __init__(self):
        self.logger = logging.getLogger("OrderService")

    @log_errors
    def process_order(self, order_id: int) -> None:
        # 實作
        pass
```

**兩個類別都可行**，因為它們滿足 `HasLogger` 協定 - 它們都有 `logging.Logger` 型別的 `logger` 屬性，不需要繼承。

### Protocol 的運作方式

當型別檢查器看到 `T = TypeVar("T", bound=HasLogger)` 時，它理解：

1. `T` 可以是任何型別
2. 但 `T` 必須有 `logging.Logger` 型別的 `logger` 屬性
3. 因此，在 decorator 內部存取 `self.logger` 是安全的

這被稱為**結構子型別**（也稱為帶型別的鴨子型別），型別檢查器檢查型別的結構，而不是其名義繼承。

### 執行時期型別檢查：@runtime_checkable

預設情況下，`Protocol` 只在靜態型別檢查時有效。如果你需要在執行時期使用 `isinstance()` 檢查物件是否符合協定，可以使用 `@runtime_checkable` 裝飾器：

```python
from typing import Protocol, runtime_checkable
import logging

@runtime_checkable
class HasLogger(Protocol):
    """具有 logger 屬性的物件的協定"""
    logger: logging.Logger

# 現在可以在執行時期檢查
class UserService:
    def __init__(self):
        self.logger = logging.getLogger("UserService")

service = UserService()
if isinstance(service, HasLogger):  # ✓ 可以運作
    print("Service has a logger")
```

**注意**：如果你不需要執行時期的 `isinstance` 檢查，就不需要 `@runtime_checkable`。對於大多數 decorator 使用情境，靜態型別檢查就足夠了。

### 真實世界範例：資料庫交易

這是經常用於資料庫操作的模式：

```python
from functools import wraps
from collections.abc import Callable
from typing import Protocol, TypeVar, Concatenate, ParamSpec

class HasDatabase(Protocol):
    """具有資料庫連線的服務協定"""
    @property
    def db(self) -> 'Database':
        ...

ServiceT = TypeVar("ServiceT", bound=HasDatabase)
P = ParamSpec("P")
R = TypeVar("R")

def transactional(
    func: Callable[Concatenate[ServiceT, P], R]
) -> Callable[Concatenate[ServiceT, P], R]:
    """在資料庫交易中執行方法"""
    @wraps(func)
    def wrapper(self: ServiceT, *args: P.args, **kwargs: P.kwargs) -> R:
        self.db.begin_transaction()  # ✓ 型別安全!
        try:
            result = func(self, *args, **kwargs)
            self.db.commit()
            return result
        except Exception:
            self.db.rollback()
            raise
    return wrapper

# 任何有 db 屬性的服務都可以使用這個 decorator:
class UserRepository:
    def __init__(self, database: 'Database'):
        self._database = database

    @property
    def db(self) -> 'Database':
        return self._database

    @transactional
    def create_user(self, email: str, age: int) -> int:
        """在交易中建立使用者"""
        user_id = self.db.execute(
            "INSERT INTO users (email, age) VALUES (?, ?)",
            (email, age)
        )
        # 更多操作...
        return user_id

    @transactional
    def delete_user(self, user_id: int) -> None:
        """在交易中刪除使用者及所有相關資料"""
        self.db.execute("DELETE FROM user_orders WHERE user_id = ?", (user_id,))
        self.db.execute("DELETE FROM users WHERE id = ?", (user_id,))
```

這個模式的優點：

- **型別安全**：`self.db` 保證存在並有正確的方法
- **靈活**：適用於任何有 `db` 屬性的類別
- **無耦合**：不需要共同的基礎類別
- **可測試**：容易建立滿足協定的測試替身

## 實際應用

### 模式 1：具有指數退避的重試

```python
import time
import random
from functools import wraps
from collections.abc import Callable
from typing import ParamSpec, TypeVar

P = ParamSpec("P")
T = TypeVar("T")

def retry(
    max_attempts: int = 3,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
    exponential_base: float = 2.0,
    jitter: bool = True
) -> Callable[[Callable[P, T]], Callable[P, T]]:
    """具有指數退避和抖動的重試函式

    為什麼要抖動? 在分散式系統中，同時重試可能會導致
    驚群問題（Thundering herd problem)。抖動會隨機化重試時間。
    """
    def decorator(func: Callable[P, T]) -> Callable[P, T]:
        @wraps(func)
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
            last_exception: Exception | None = None

            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e

                    if attempt < max_attempts - 1:
                        # 計算指數退避
                        delay = min(
                            base_delay * (exponential_base ** attempt),
                            max_delay
                        )

                        # 加入抖動以防止驚群
                        if jitter:
                            delay = delay * (0.5 + random.random())

                        print(f"嘗試 {attempt + 1} 失敗: {e}。{delay:.2f}s 後重試...")
                        time.sleep(delay)

            assert last_exception is not None
            raise last_exception

        return wrapper
    return decorator

# 使用 - 完全型別檢查:
@retry(max_attempts=5, base_delay=0.5)
def fetch_api_data(endpoint: str, timeout: int = 30) -> dict:
    """從外部 API 取得資料"""
    import requests
    response = requests.get(endpoint, timeout=timeout)
    response.raise_for_status()
    return response.json()

# 型別檢查器驗證:
data: dict = fetch_api_data("https://api.example.com/data", timeout=10)  # ✓
# fetch_api_data(123)  # ✗ 型別錯誤:預期 str
```

**為什麼這個模式有價值**：網路呼叫會失敗，API 不可靠，重試邏輯很重要但容易出錯。這個 decorator 封裝了最佳實踐(指數退避、抖動、最大延遲)，同時保持完整的型別安全。

### 模式 2：速率限制

```python
import time
from collections import deque
from functools import wraps
from collections.abc import Callable
from typing import Protocol, TypeVar, Concatenate, ParamSpec

class HasRateLimiter(Protocol):
    """具有速率限制的物件協定"""
    _rate_limit_calls: deque[float]

ServiceT = TypeVar("ServiceT", bound=HasRateLimiter)
P = ParamSpec("P")
R = TypeVar("R")

def rate_limit(
    calls_per_second: int
) -> Callable[
    [Callable[Concatenate[ServiceT, P], R]],
    Callable[Concatenate[ServiceT, P], R]
]:
    """將方法呼叫速率限制為指定的每秒呼叫次數

    使用滑動視窗演算法進行準確的速率限制。
    """
    def decorator(
        func: Callable[Concatenate[ServiceT, P], R]
    ) -> Callable[Concatenate[ServiceT, P], R]:
        @wraps(func)
        def wrapper(self: ServiceT, *args: P.args, **kwargs: P.kwargs) -> R:
            # 如需要，初始化速率限制器
            if not hasattr(self, "_rate_limit_calls"):
                self._rate_limit_calls = deque()

            now = time.time()
            window_start = now - 1.0  # 1 秒視窗

            # 移除視窗外的呼叫
            while self._rate_limit_calls and self._rate_limit_calls[0] < window_start:
                self._rate_limit_calls.popleft()

            # 檢查速率限制
            if len(self._rate_limit_calls) >= calls_per_second:
                sleep_time = self._rate_limit_calls[0] + 1.0 - now
                if sleep_time > 0:
                    time.sleep(sleep_time)
                    now = time.time()

            # 記錄此次呼叫
            self._rate_limit_calls.append(now)

            return func(self, *args, **kwargs)

        return wrapper
    return decorator

class APIClient:
    """具有速率限制的外部 API 客戶端"""

    def __init__(self):
        self._rate_limit_calls: deque[float] = deque()

    @rate_limit(calls_per_second=10)
    def fetch_user(self, user_id: int) -> dict:
        """取得使用者資料(速率限制為 10 次呼叫/秒)"""
        # API 呼叫實作
        return {"id": user_id, "name": "Alice"}

    @rate_limit(calls_per_second=5)
    def update_user(self, user_id: int, data: dict) -> None:
        """更新使用者資料(速率限制為 5 次呼叫/秒)"""
        # API 呼叫實作
        pass
```

**為什麼 Protocol 在這裡很重要**：decorator 需要在實例上儲存狀態（`_rate_limit_calls`），沒有 Protocol 的話，型別檢查器會抱怨存取這個屬性，Protocol 宣告：「這個 decorator 只能用於有 `_rate_limit_calls` 的物件。」

### 模式 3：效能指標收集

```python
import time
from functools import wraps
from collections.abc import Callable
from typing import Protocol, TypeVar, Concatenate, ParamSpec

class HasMetrics(Protocol):
    """具有效能指標收集的物件協定"""
    def record_metric(self, name: str, value: float, tags: dict[str, str]) -> None:
        ...

ServiceT = TypeVar("ServiceT", bound=HasMetrics)
P = ParamSpec("P")
R = TypeVar("R")

def collect_metrics(
    metric_name: str | None = None
) -> Callable[
    [Callable[Concatenate[ServiceT, P], R]],
    Callable[Concatenate[ServiceT, P], R]
]:
    """為方法呼叫收集時間和計數指標"""
    def decorator(
        func: Callable[Concatenate[ServiceT, P], R]
    ) -> Callable[Concatenate[ServiceT, P], R]:
        name = metric_name or func.__name__

        @wraps(func)
        def wrapper(self: ServiceT, *args: P.args, **kwargs: P.kwargs) -> R:
            start = time.time()
            success = False

            try:
                result = func(self, *args, **kwargs)
                success = True
                return result
            finally:
                elapsed = time.time() - start

                # 記錄時間指標
                self.record_metric(
                    f"{name}.duration",
                    elapsed,
                    {"success": str(success)}
                )

                # 記錄計數指標
                self.record_metric(
                    f"{name}.calls",
                    1,
                    {"success": str(success)}
                )

        return wrapper
    return decorator

class UserService:
    """具有效能指標收集的使用者服務"""

    def __init__(self, metrics_client):
        self.metrics_client = metrics_client

    def record_metric(self, name: str, value: float, tags: dict[str, str]) -> None:
        """將指標記錄到指標後端"""
        self.metrics_client.record(name, value, tags)

    @collect_metrics("user.create")
    def create_user(self, email: str, age: int) -> int:
        """建立使用者，自動收集效能指標"""
        # 實作
        return 123

    @collect_metrics()  # 使用方法名稱作為指標名稱
    def delete_user(self, user_id: int) -> None:
        """刪除使用者，自動收集效能指標"""
        # 實作
        pass
```

**為什麼這在生產環境中很重要**：可觀察性是關鍵，每個服務都需要指標。這個模式讓加入全面的指標收集變得容易達成，而不會讓業務邏輯變得雜亂。Protocol 確保型別安全，同時允許在如何記錄指標上的靈活性。

## Lesson Learned 和 Best Practices

### 1. 關於 `from __future__ import annotations` 的使用建議

這個 import 在 Python 3.7+ 被廣泛使用來處理型別標註：

```python
from __future__ import annotations

from typing import TypeVar, ParamSpec
```

**這個功能提供的好處：**

- 前向引用（可以在定義之前引用類別）
- 更好的效能（annotations 不會在 import 時被評估）

**版本演進與未來走向：**

- **Python 3.14**：[PEP 749](https://peps.python.org/pep-0749/) 已實作，`from __future__ import annotations` 最終將會 deprecated 並預計在 Python 3.13 EOL 後終將被移除。
- **參考資料**：詳見 [Python 3.14 What's New](https://docs.python.org/3.14/whatsnew/3.14.html) 與 [__future__ 文件](https://docs.python.org/3.14/library/__future__.html)

```python
from __future__ import annotations
from collections.abc import Callable
from typing import TypeVar, ParamSpec, Concatenate
```

**關於 `Callable` 的選擇**：從 Python 3.9 開始，[官方文件建議](https://docs.python.org/3/library/typing.html#typing.Callable)使用 `collections.abc.Callable` 而非 `typing.Callable`（後者為過時別名）。

### 2. 優先使用 ParamSpec 而不是 `Callable[..., T]`

在撰寫 decorator 時，**總是**使用 `ParamSpec`，除非你有特定的理由不這麼做：

```python
from collections.abc import Callable
from typing import ParamSpec, TypeVar

# ✗ 避免這樣
def decorator(func: Callable[..., T]) -> Callable[..., T]:
    pass

# ✓ 這樣做
P = ParamSpec("P")
T = TypeVar("T")

def decorator(func: Callable[P, T]) -> Callable[P, T]:
    pass
```

額外的冗長是值得的，因為你獲得的型別安全。

**重要：ParamSpec 與 functools.wraps 是互補的**

- **`ParamSpec`** 保留**靜態型別簽名** - 型別檢查器使用它來驗證呼叫
- **`functools.wraps`** 保留**執行時期元資料** - 如 `__name__`、`__doc__`、`__module__`、`__wrapped__`

兩者都應該使用，以獲得完整的型別安全和正確的執行時期行為：

```python
from functools import wraps
from collections.abc import Callable
from typing import ParamSpec, TypeVar

P = ParamSpec("P")
T = TypeVar("T")

def decorator(func: Callable[P, T]) -> Callable[P, T]:
    @wraps(func)  # 保留執行時期元資料
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:  # 保留靜態型別
        return func(*args, **kwargs)
    return wrapper
```

如果沒有 `@wraps`，工具如 `inspect.signature()` 和 IDE 在執行時期將無法正確顯示原始函式的元資料。

### 3. 對方法裝飾器使用有界 TypeVar

對於實例方法的 decorator，如果你需要存取實例屬性，**總是**使用有界 TypeVar：

```python
from collections.abc import Callable
from typing import Concatenate, ParamSpec, Protocol, TypeVar

# ✗ 這不會運作
T = TypeVar("T")
P = ParamSpec("P")
R = TypeVar("R")

def decorator(func: Callable[Concatenate[T, P], R]) -> ...:
    def wrapper(self: T, ...):
        self.some_attribute  # 型別錯誤!

# ✓ 使用 Protocol
class HasAttribute(Protocol):
    some_attribute: SomeType

T = TypeVar("T", bound=HasAttribute)

def decorator(func: Callable[Concatenate[T, P], R]) -> ...:
    def wrapper(self: T, ...):
        self.some_attribute  # ✓ 運作
```

### 4. Protocol vs ABC：何時使用哪個

使用 `Protocol` 當：

- 你在為現有程式碼定義介面
- 你想要結構型別（帶型別的鴨子型別）
- 你想要避免耦合

使用 `ABC` 當：

- 你在建立真正的繼承階層
- 你想要共享實作程式碼
- 你需要執行時期型別檢查（`isinstance`）

## 參考資料

1. [**PEP 484 – Type Hints**](https://peps.python.org/pep-0484/)

2. [**PEP 612 – Parameter Specification Variables**](https://peps.python.org/pep-0612/)

3. [**PEP 544 – Protocols: Structural subtyping**](https://peps.python.org/pep-0544/)

4. [**typing 模組文件**](https://docs.python.org/3/library/typing.html)
