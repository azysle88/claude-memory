---
name: project-workflow
description: hdreport 專案跨機器工作流程 — 2026-05-30 起改用 GitHub sync，本機路徑統一 C:\projects\hdreport
metadata:
  node_type: memory
  type: project
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

## 當前工作流程（2026-05-30 起）

- **本機路徑**：兩台機器都用 `C:\projects\hdreport`（HeavenTUF + HeavenZ13 同路徑）
- **同步方式**：純 GitHub（git push/pull），**不再透過 Google Drive 同步檔案**
- **Claude Code session**：兩台都可以跑（本機路徑相同，memory 路徑也會一致）

## 舊流程（已停用）

- ~~G:\其他電腦\HeavenZ13\project\hdreport~~ — Google Drive 同步路徑（已停用）
- ~~只在 HeavenTUF 跑 session~~ — 已不適用

## 切換動作 checklist（已完成）

- [x] 把 G:\其他電腦\HeavenZ13\project\hdreport 內容搬到 C:\projects\hdreport
- [x] 確認 GitHub remote (origin) 設定正確
- [x] 之後在新機器：git clone https://github.com/azysle88/hdreport.git C:\projects\hdreport

## Memory 路徑注意

舊 session 的 memory 在：
`C:\Users\azysl\.claude\projects\G-------HeavenZ13-project-hdreport\memory\`

未來在 `C:\projects\hdreport` 開新 session，memory 會落在不同路徑（推測 `C--projects-hdreport`）。需要時可手動複製過去。

## 路徑引用注意

memory 內所有 `G:\其他電腦\HeavenZ13\project\hdreport\` 開頭的絕對路徑都要改成 `C:\projects\hdreport\`。
