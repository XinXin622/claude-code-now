---
description: 提交代码更改到 Git 仓库
---

# 提交代码

## 查看更改状态
// turbo
```bash
git status
```

## 查看详细更改（用于生成 commit message）
// turbo
```bash
git diff --cached --stat
git diff --stat
```

## 自动生成 Commit Message

根据更改内容自动生成 commit message：
1. 分析 `git status` 和 `git diff` 输出
2. 识别更改类型（feat/fix/docs/chore 等）
3. 生成简洁的描述

## 提交所有更改
// turbo
```bash
git add .
git commit -m "自动生成的 commit message"
```

## 推送到远程
// turbo
```bash
git push origin main
```

## Commit 类型参考

| 类型 | 用途 |
|------|------|
| `feat:` | 新功能 |
| `fix:` | 修复 bug |
| `docs:` | 文档更新 |
| `style:` | 代码格式（不影响功能） |
| `refactor:` | 重构代码 |
| `chore:` | 构建/工具/配置变动 |
| `build:` | 构建系统或外部依赖变动 |
