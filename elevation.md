---
title: "elevation"
date: 2022-05-06T02:06
description: "在 [[Material Design]] 中，Elevation 用於表達 Surface 的高度，以凸顯視覺層級和空間感..."
---
在 [[Material Design]] 中，Elevation 用於表達 Surface 的高度，以凸顯視覺層級和空間感。
Measuring elevation
	-  Elevation 是兩個 [[surface]] 在 z 軸上的相對距離，此距離的衡量方式為兩個 [[surface]] 在 z 軸上的 [[density independent pixel]] (dp)，而描繪 elvation 的方式是透過 [[shadow]]
- 描繪 elevation 的方式除了 shadow 外也可以透過填充不同的顏色或透明度來達到，然而卻不能表達各個 [[surface]] 間相對高度的程度
	![Pasted image 20210913130451.png](https://i.imgur.com/ft3vM82.png)（透過不同填充顏色表達不同高度）![Pasted image 20210913130500.png](https://i.imgur.com/QqCxMwE.png)（透過透明度表達不同高度）
- Elevation System
	- 在 [[Material Design]] 中所有的 [[components]]、[[surface]] 都有 elevation
	- elevation 有三項功用：
		- 凸顯兩個 [[surface]] 的前後順序，如 [[App Bar]] 會在內容前面，而不會受到滾到影響。
		- 凸顯 [[surface]] 的空間感，例如 [[floating action button]] 的影子代表他遠離了背後的 [[card]]。
		- 提高較高的元件的視覺層級，吸引注意力，例如彈跳視窗，對話框（[[dialog]]）等
- 所有元件都有各自初始的 elevation: [[resting elevation]]
- Change elevation
	- 當進行互動時，元件的 elevation 會從 [[resting elevation]] 移動至預設的 [[dynamic elevation offsets]]，當互動結束時會回到 [[resting elevation]]
	- elevation 更動時可能會與其他元件衝突，此時是可以暫時移動並非重點的元件，避免衝突發生，讓畫面簡單化。
- 要成功描繪 elevation，[[surface]] 需要可以表達下列三點特點
	- surface edge：凸顯每個 [[surface]] 的邊界外圍，透過 UI 中不同部分分成可辨識的元件來表達 [[surface]] 的結束與另一個 [[surface]] 的開始，[[Material Design]] 中的 [[surface]] 使用 [[shadow]] 來達到，另外也可以透過不同的顏色或透明度達到。
		- 不同 [[surface]] 顏色需有充分的對比，才能夠做出區隔。
	- surface 之間的重疊，無論是在靜止狀態或是動畫進行中，表達了兩個 [[surface]] 的不同 elevation，高的 [[surface]] 有著較高的 z 值並且在介面上會在較低 elevation 的 [[surface]] 前方。
	- 與其他 surface 的 z 軸距離，表達不同 [[surface]] elevation 的差異，可以透過調暗背景或是使用 [[shadow]]，調暗背景的方式可以表達明顯大量 elevation 差異但缺乏對不同 [[surface]] 的針對性。
- 動畫可以突現 elevation 的差異，其中動畫包含
	- 改變 [[shadow]] 大小和模糊程度
	- 展現重疊
	- Pushing 其他元件
	- Scaling 元件
	- Parallax 利用不同速度達成視差（越高越近移動較慢，越遠移動較快）
- elevation 可以用於表達內容的重要性，較高的內容可能代表他可以操作較低的內容（[[floating action button]]）、吸引注意力（[[dialog]]）或是較為重要因此需要較高的層級。反之若內容在同一個平面上則代表有相同的重要性
- [Default elevation](https://material.io/design/environment/elevation.html#default-elevations)
![Pasted image 20210913141621.png](https://i.imgur.com/K63R96H.png)


- Reference
	- https://material.io/design/environment/elevation.html