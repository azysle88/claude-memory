# Memory Index

- [墨客人類圖專案](project_hdreport.md) — 付費報告網站，PHP+MySQL，藍新+Claude API+Telegram Bot，技術架構與待辦事項
- [跨機器工作流程](project_workflow.md) — Claude Code session 固定在 HeavenTUF 跑，HeavenZ13 走遠端，不另設 memory 同步
- [藍新金流串接規則](feedback_newebpay.md) — MerchantOrderNo格式、RespondType=JSON、PRG模式、notify不同步生成等必套規則
- [藍新金流實作範本位置](reference_newebpay_skill.md) — 完整 PHP skill 在 hdreport/skills/newebpay.md
- [Telegram Bot 串接坑](telegram_bot_lessons.md) — 已讀不回、Email 連結無反應、多訂單切換、AI 超出範圍、訊息截長等已解決問題
- [Cron + 付費 API 安全規則](feedback_cron_api_safety.md) — 狀態機/重試上限/DB重連/spend limit 等防 runaway loop 規則（hdreport 因缺這些燒 $280）
- [PHP PDO 常見坑](feedback_php_pdo_pitfalls.md) — named param 不能重用、LIMIT 必須 PARAM_INT、長操作後斷線等
- [回覆語言偏好](feedback_language.md) — 一律用繁體中文，不要英文
- [禁止竄改客戶原始資料](feedback_no_modify_customer_data.md) — 計算錯誤要修程式，不可改 DB 客戶輸入
- [mPDF 報告生成踩坑指南](reference_mpdf_skill.md) — hdreport/skills/mpdf_pdf_generation.md，可複製到其他專案
- [付費 API 部署 checklist](reference_paid_api_checklist.md) — hdreport/skills/paid_api_deployment_checklist.md，新專案接 Claude/OpenAI 前必跑
- [PowerShell 5.1 編碼坑](feedback_powershell_encoding.md) — .ps1 必須 UTF-8 with BOM，否則中文被當 CP950 亂碼
- [正式機部署與環境](reference_deploy.md) — SSH/FTP 連線、pyswisseph 已裝、scp targeted 部署（勿用全量 deploy.php 覆蓋 .env）
- [報告封測與改版方向](project_beta_feedback.md) — 純匿名問卷已上線、TA=初學者、報告內容待改版（去AI腔/稀釋術語/短報告+補充）
