---
name: feedback-powershell-encoding
description: 寫 .ps1 / .psm1 給 Windows PowerShell 5.1 用時，必須是 UTF-8 with BOM，否則中文字串會被當 CP950 誤解析
metadata:
  type: feedback
---

寫任何 PowerShell 腳本給 Windows PowerShell 5.1 (powershell.exe) 用時，**檔案編碼必須是 UTF-8 with BOM**。

**Why:** Windows PowerShell 5.1 預設不認得無 BOM 的 UTF-8，會用系統 codepage（繁中環境是 CP950 / Big5）解析，中文字串內容會變亂碼，PowerShell parser 拋 "無法辨識的語彙基元" 與「字串遺漏結尾字元」錯誤。2026-05-30 在 sync_memory.ps1 踩過。

**How to apply:**
- Write tool 預設輸出無 BOM 的 UTF-8 → 寫完 .ps1 / .psm1 / .ps1xml 後一定要追加 BOM
- 補正方式：用 PowerShell tool 跑 `[System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($true))`
- 或一律避免在 PowerShell 腳本內寫中文（全用英文 string + comment）— 但這對使用者可讀性差
- PowerShell 7+ 對無 BOM UTF-8 友善，但本 user 的環境是 5.1，不能假設

**對應 memory：** 同類問題在其他 Windows 工具不會出現（cmd.exe / wsl bash / Python / Node 都可以讀無 BOM UTF-8）— 此規則僅針對 .ps1 系列檔案。
