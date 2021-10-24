## 什麼是 Coverage.py
Coverage.py 是一個用於檢查測試覆蓋率的套件，他會監控程式碼，紀錄哪些部分有執行過、檢查哪些部分有測試過哪些未有測試。
## Quick Start
1. 安裝 coverage
	使用 pip：

	```bash
	pip install coverage
	```
	使用 poetry:
	```bash
	poetry add -D "coverage[toml]"
	```
	可以在 `pyproject.toml` 中加入下列設定，使其只針對專案本身檢測並設定標準為 100% 覆蓋：
	```toml
	[tool.coverage.run]  
	omit = [".*", "*/site-packages/*"]
	[tool.coverage.report]  
	fail_under = 100  
	```

2. 透過 `coverage run` 指令執行 coverage：
	選項部分帶入 `-m` 會透過調用 `python -m` 來執行，因此只需要帶入過去執行測試時的指令作為參數即可使用，例如使用 [[pytest]] 可以輸入指令 `coverage run -m pytest`
3. 透過 `coverage report` 產出報告：
	```bash
	$ coverage report -m
	Name                      Stmts   Miss  Cover   Missing
	-------------------------------------------------------
	my_program.py                20      4    80%   33-35, 39
	my_other_module.py           56      6    89%   17-23
	-------------------------------------------------------
	TOTAL                        76     10    87%
	```
	>  Note. `-m` 選項用於顯示會被覆蓋的程式碼行數



## FAQ
1. Question. 如何取消特定區塊的 coverage 檢查：
	Ans. 在該區塊開頭加入 `# pragma: no cover`