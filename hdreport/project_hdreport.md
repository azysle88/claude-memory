---
name: project-hdreport
description: 墨客人類圖付費報告網站專案背景、技術架構與目前狀態
metadata: 
  node_type: memory
  type: project
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

人類圖付費報告網站，使用者填出生資料 → 藍新金流付款 → Claude API 生成報告 → PDF 寄 Email。Telegram Bot 提供諮詢。

**Why:** 商業產品，需要完整付款、報告生成、Email 交付流程，加上 Telegram Bot 諮詢服務。

**How to apply:** 每次修改都要考量這三條主線：付款流程、報告生成流程、Telegram Bot 流程。每個段落結束要產出 DEVLOG.md 筆記並三端同步（本機、production、GitHub）。

## 技術選型
- PHP 8.3（production）/ 8.2（local） + MySQL 8.0.45
- 付款：藍新金流（測試環境 `https://ccore.newebpay.com/MPG/mpg_gateway`）
- LLM：Claude API（`claude-sonnet-4-6`）
- PDF：mPDF 8.x
- Email：PHPMailer 6.x（SMTP: osa1.hostclusters.com:465）
- Telegram：Bot webhook 已設定
- 本機：`C:\project\hdreport`（Google Drive 同步）
- 部署：FTP（ftp.humanhd.com）+ SSH（172.233.91.81:19199, user: humanhd）
- GitHub：https://github.com/azysle88/hdreport（private, branch: main）

## Production 主機
- 網域：https://report.humanhd.com
- 專案路徑：~/report.humanhd.com/
- SSH key：.ssh/hddr_id_rsa（passphrase）/ hddr_id_rsa_nopass（無密碼，供腳本用）
- FTP root = Web root（無 public_html 子目錄）
- DB：localhost:3306 / humanhd_hddreport / humanhd_hhdrdev
- 本機 .env 用 DB IP；production .env 用 localhost

## 重要設計決策
- `public/bootstrap.php`：動態偵測 APP_ROOT（本機 public/ 子目錄 vs production web root）
- `notify.php`：只標記 paid，**不**同步生成報告（避免 callback timeout）
- Cron：`* * * * *` 每分鐘掃 paid 訂單 → 非同步生成 → log 至 tmp/cron.log
- `.htaccess`：封鎖 src/ vendor/ config/ .env 等敏感目錄

## 常用指令
```powershell
php scripts/deploy.php                          # FTP 完整部署
php scripts/ftp_upload_file.php <local> <remote> # 單檔上傳
ssh -i .ssh\hddr_id_rsa_nopass -p 19199 humanhd@172.233.91.81  # SSH
# 查 cron log：tail -f ~/report.humanhd.com/tmp/cron.log
php scripts/setup_webhook.php                   # 設定 Telegram webhook
```

## 報告交付方式（2026-05-22 確定版）
- Claude 生成完整 MUSEON HTML（含 CSS vars、Google Fonts、多 Layer 結構）
- `Pdf/Generator::prepareForMpdf()` 做 CSS 相容性轉換（展開 vars、處理 clamp/vh、修正 gradient-text、移除動畫）
- mPDF 渲染 HTML → PDF（mode=zh-TW, default_font=cid0tc）
- Email 正文含 HD 摘要（meta-pills + Layer 0 詩意句 + 設計摘要）+ PDF 附件
- **不提供連結**（無法確認收件者身份）
- `skills/report.md` = Claude 系統提示：HTML 模板規格 + HD 知識庫 + Layer 撰寫指南

## Email 設定（2026-05-27 更新）
- 原本用 osa1.hostclusters.com SMTP，因 runaway loop 燒壞 IP 信譽被 Gmail 451 拒絕
- 改用 **Resend**（smtp.resend.com:465, user: resend, pass: API key）
- 網域 report.humanhd.com 已在 Resend 驗證完畢
- Cloudflare 已加 SPF / DKIM / DMARC for report.humanhd.com

## 目前狀態（2026-05-27）
- [x] 完整程式碼骨架
- [x] GitHub Repo 建立並 push
- [x] .env 設定（production 用 localhost DB）
- [x] DB Migration（5 張表，含 generation_retry + api_usage_log）
- [x] FTP 部署上線
- [x] Telegram Webhook 設定
- [x] 藍新 Notify/Return URL 設定
- [x] Cron 非同步報告生成（狀態機 + 重試上限 + 卡單回收）
- [x] HTML 報告格式（對齊 MUSEON 設計模板）
- [x] skills/report.md（HD 知識庫 + HTML 模板規格）
- [x] API 用量監控（api_usage_log + Telegram 即時通知 + 每日 digest）
- [x] 端對端測試通過（付款 → cron → Claude → PDF → Resend Email 進 Gmail 收件匣）
- [ ] API_USAGE_NOTIFY=1 測試完畢後關閉
- [ ] skills/report.md 補強（MUSEON 完整知識內容）
- [ ] 切換藍新正式環境
