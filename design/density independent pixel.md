---
title: "density independent pixel"
date: 2022-05-06T02:06
dg-publish: true
dg-permalink: "design/density independent pixel"
description: "[[density independent pixel]] 又稱 dp（or dip），是 Android 設備介面尺寸單位，為了解決不同設備上 [[pixel density]] 不同會顯示不同大小的介面，而發明的統一尺寸單位..."
---
[[density independent pixel]] 又稱 dp（or dip），是 Android 設備介面尺寸單位，為了解決不同設備上 [[pixel density]] 不同會顯示不同大小的介面，而發明的統一尺寸單位。

Android 設定在 160 ppi 的設備上，1dp 為 1px。而在其他不同的 ppi 設備上呈現相同的介面時，相同 1dp 會調整呈現的像素數量，如在 320 ppi 的設備上，由於會若只呈現 1px 的話畫面相較 160ppi 會縮小一倍，因此相同 1dp 在 320 ppi 的設備上會呈現 2px，以追求統一的大小呈現。

相同的概念在 iOS 系統上稱之為 pt (point)，而 CSS 中的 pt 是不同概念，其主要用於 web 輸出印刷時所使用單位，1 pt 為 1/72 英吋。
## Reference
- [Material Design](https://material.io/design/layout/pixel-density.html#pixel-density)
- [Pixel Density (Wikipedia)](https://en.wikipedia.org/wiki/Pixel_density)
- [徹底理解 UI 及 Web 的尺寸單位：基本觀念](https://medium.com/uxabc/understanding-ui-units-8acdc0575388)