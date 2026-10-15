---
name: reference-claude-notify
description: Claude Code 作業完成通知（語音 / 提示音 / 靜音）可切換腳本，位於 tools/claude-notify.ps1，目前模式為語音
metadata:
  node_type: memory
  type: reference
---

## 目前模式：voice（語音）

2026-10-14 曾切成 beep，2026-10-15 切回 voice。

## 檔案

- `tools/claude-notify.ps1` — Stop hook 實際執行的通知腳本（讀 stdin JSON 後丟掉，依模式播放）
- `tools/claude-notify-mode.ps1` — 切換工具

## 切換方式（任一台 Windows 機器）

```powershell
cd <claude-memory 本機路徑>\tools
.\claude-notify-mode.ps1 voice   # 語音播報（預設）
.\claude-notify-mode.ps1 beep    # 單純提示音
.\claude-notify-mode.ps1 off     # 靜音
.\claude-notify-mode.ps1         # 看目前模式
.\claude-notify-mode.ps1 test    # 立刻播一次
```

模式存在 `%USERPROFILE%\.claude\notify-mode.txt`，每台機器各自設定。
臨時覆寫可用環境變數 `CLAUDE_NOTIFY_MODE`（優先於設定檔）。
找不到設定檔時預設 voice。

## 接到 Claude Code 的 Stop hook

在 `C:\Users\azysl\.claude\settings.json` 把原本的語音 hook 指令換成：

```json
"hooks": {
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\projects\\claude-memory\\tools\\claude-notify.ps1"
        }
      ]
    }
  ]
}
```

路徑依 claude-memory 實際 clone 位置調整。改完 settings.json 要重開 Claude Code session 才生效。

## 注意

- 兩支 .ps1 都是 UTF-8 with BOM，否則中文註解在 PowerShell 5.1 會亂碼（見 [[feedback_powershell_encoding]]）。
- 語音播報失敗（缺 System.Speech）會自動退回提示音，不會讓 hook 報錯。
