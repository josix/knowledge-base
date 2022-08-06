---
title: "Pytest.fixture"
date: 2022-05-06T02:10
---
## Pytest Fixtures 是什麼
[[Pytest]] 的 Fixtures 是進行[[軟體測試]]籌備（Arrange）階段時，用於準備測試所需物件、環境的函式。在 Pytest 中，只需要在 test case 中直接加入已經定義好的 fixture name 作為參數，則可以直接使用該 fixture，test case 可以調用多個定義好的 fixture ，fixture	 也可以調用其他 fixture，因此 fixture 是相當彈性、可擴充並且是明確定義的（explicit）。

## Start from a Quick Example
```python
import pytest

class Fruit:
    def __init__(self, name):
        self.name = name

    def __eq__(self, other):
        return self.name == other.name

@pytest.fixture
def my_fruit():
    return Fruit("apple")

@pytest.fixture
def fruit_basket(my_fruit):
    return [Fruit("banana"), my_fruit]

def test_my_fruit_in_basket(my_fruit, fruit_basket):
    assert my_fruit in fruit_basket

def test_fruit_name_is_string(my_fruit):
    assert type(my_fruit.name) is str
````
- 透過 `pytest.fixture` 這個 decorator 可以將函式中的回傳值作為 test case 可以使用的 fixture。
- 透過在 test/fixture 中加入參數可以調用定義好的 fixture。
- Fixture 也可以調用其他 fixture，見 `fruit_basket`，而其中已經調用過的 fixture (`my_fruit`）回傳值會被 cached，並且在 `test_my_fruit_in_basket` 這個 test 被調用時其狀態已經改變。
- Fixture 可以重複使用於多個 test 和 fixture 中，見（`test_my_fruit_in_basket`, `test_fruit_name_is_string`, `fruit_basket`）
- Test 可以同時使用多個 fixture，見（`test_my_fruit_in_basket`）