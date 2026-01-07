---
description: 发布新版本到 GitHub（创建 tag 并触发 GitHub Actions 构建和发布）
---

# 发布新版本

## 前置条件
- 确保所有更改已提交
- 确保代码已推送到远程仓库

## 发布步骤

### 1. 确认版本号
版本号格式支持：
- `1.0.0` - 正式版本
- `1.0.0-beta` - Beta 版本
- `1.0.0-rc.1` - Release Candidate

### 2. 创建并推送 Tag
// turbo
```bash
# 替换 VERSION 为实际版本号，如 1.0.0
git tag vVERSION
git push origin vVERSION
```

### 3. 验证发布
1. 打开 GitHub 仓库 → Actions 标签
2. 查看 "Build macOS Apps" 工作流是否正在运行
3. 构建完成后检查 Releases 页面

## 回滚操作（如果需要）

### 删除错误的 Tag
```bash
# 删除本地 tag
git tag -d vVERSION

# 删除远程 tag
git push origin --delete vVERSION
```

### 删除 Release
在 GitHub 网页上：仓库 → Releases → 找到对应 Release → Delete

## 测试构建（不发布 Release）

使用 GitHub Actions 手动触发：
1. 仓库 → Actions → "Build macOS Apps"
2. 点击 "Run workflow"
3. 输入版本号（如 `0.0.1-test`）
4. 点击 Run workflow
