---
tags: Tool Sharing, draft
---
# 淺析 GitHub Page Deploy Action 運作原理

[TOC]

---

## GitHub Action 是什麼
## GitHub Page 是什麼
## GitHub Page 自動部署所需步驟
## 如何撰寫 Workflow
### Workflow 基本概念
### Workflow 格式
### Context and expression syntax for GitHub Actions

## 開始實作
### actions/checkout
### Install Dependencies
### Running build scripts
### 推更新內容至 `gh-pages`
#### 使用 git worktree 在原 Repository 拉取並更新內容
#### rsync 覆蓋原有內容
## 淺析 GitHub Page Deploy Action 運作原理

## Reference
- https://docs.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions
- https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#onpushpull_requestbranchestags
- https://milkmidi.medium.com/%E6%B7%B1%E5%85%A5%E4%BD%86%E4%B8%8D%E6%B7%BA%E5%87%BA-%E5%A6%82%E4%BD%95%E7%94%A8-github-actions-%E8%87%AA%E5%8B%95%E7%99%BC%E4%BD%88-gh-pages-8183464dfe84
- https://github.com/pycontw/pycontw-2021/runs/3192982747?check_suite_focus=true
- https://github.com/JamesIves/github-pages-deploy-action/tree/dev/src
- https://github.com/josix/commitizen/blob/master/.github/workflows/pythonpublish.yaml
- https://kmsheng.medium.com/%E4%BD%BF%E7%94%A8-git-worktree-%E5%BB%BA%E7%AB%8B%E5%A4%9A%E5%80%8B%E5%B7%A5%E4%BD%9C%E5%8D%80-5a02f6d9d3fd
- https://louis383.medium.com/git-worktree-%E7%B0%A1%E5%96%AE%E4%BB%8B%E7%B4%B9%E8%88%87%E4%BD%BF%E7%94%A8-876897c797bf
- https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix
- https://docs.github.com/en/actions/reference/events-that-trigger-workflows#workflow_dispatch