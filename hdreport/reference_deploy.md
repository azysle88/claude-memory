---
name: reference-deploy
description: hdreport 正式機部署方式、SSH/FTP 連線、runtime 環境（pyswisseph 等）
metadata: 
  node_type: memory
  type: reference
  originSessionId: 86d11d44-e7a6-42d8-97d7-f0c1c64f2c0c
---

hdreport 正式機（report.humanhd.com）部署與環境重點。

**連線**
- SSH：`scripts/sshexec.ps1` 風格 → `ssh -i <key> -p 19199 humanhd@172.233.91.81`，金鑰用 `.ssh/hddr_id_rsa_nopass`（在 Windows 上首次用要先 `icacls <key> /inheritance:r /grant:r "$env:USERNAME:(R)"` 收緊權限，否則 SSH 拒絕）
- 專案路徑：`/home/humanhd/report.humanhd.com`（src/ scripts/ vendor/ 都在此）
- FTP：`ftp.humanhd.com:21`，帳號 `hddrdev@report.humanhd.com`，根目錄 `/` = 專案根

**Runtime（已確認 2026-06-01）**
- PHP 8.3.31、Python 3.6.8（只有 `python3`，無 `python`）
- **`pyswisseph` 已裝**（`~/.local/lib/python3.6/site-packages/`）→ 人體圖計算可用
- 注意 Python 3.6：`-X utf8` 是 3.7 才有，但 3.6 對未知 -X 是「忽略不報錯」，且 Linux locale 預設 UTF-8，故 `python3 -X utf8` 安全（CP950 亂碼只有 Windows 才有）

**部署方式**
- `scripts/deploy.php` 是**全量** FTP 上傳，且會用本機 `.env` 覆蓋正式機 `.env`、重傳整包 vendor → 只動幾個檔時不要用
- 改幾個檔時用 **scp targeted 上傳**：`scp -i <key> -P 19199 <local> humanhd@172.233.91.81:report.humanhd.com/<path>`
- `deploy.php` 的 `$backendDirs` **不含 scripts/** → 計算腳本要單獨上傳
- 部署後務必：正式機 `php -l` + 跑端到端煙霧測試（calcChartData → BodyGraph::generate → Generator::render 產 PDF）
- 正式機**非 git repo**（FTP/scp 部署，不能在伺服器 git pull）

**crontab 操作（踩過雷）**
- 改 crontab **一律用完整清單重設**：`printf '%s\n' '行1' '行2' '行3' | crontab -`
- **絕不要用** `(crontab -l; echo '新行') | crontab -` 這種一行串——在非互動 SSH 下 `crontab -l` 可能回空，結果把現有排程全洗掉（2026-06-01 差點弄掉每分鐘的 cron_generate_reports）
- 現有三條（依序）：`cron_generate_reports`（每分鐘）、`cron_api_daily_digest`（9:00）、`cron_feedback_reminder`（11:00），PHP 路徑是 `/usr/local/bin/php`
- run_migration.php 在正式機跑不出輸出/沒作用 → 改用自帶 PDO + 錯誤回報的小腳本直接跑 ALTER（用 config/app.php 連線，不靠 bootstrap.php）

通用部署原則見 [[reference_paid_api_checklist]] 的「執行環境相依」段。
