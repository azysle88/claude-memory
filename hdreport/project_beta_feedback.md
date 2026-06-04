---
name: project-beta-feedback
description: 報告封測進度、回饋機制現況、以及報告內容改版的待辦方向
metadata: 
  node_type: memory
  type: project
  originSessionId: 86d11d44-e7a6-42d8-97d7-f0c1c64f2c0c
---

hdreport 報告品質迭代的進度與方向（2026-06-02 起）。

**封測與回饋機制（已上線）**
- 已建純匿名 Google 表單（問卷在 `docs/feedback_survey.md`；自動建表腳本 `docs/feedback_form_appsscript.gs`）。維持**純匿名**——靠 Q1 自報接觸程度分群即可，換取誠實度。
- 機制已 live：報告信底部顯示回饋預告；報告寄出約 1 天後，cron（每日 11:00 `cron_feedback_reminder.php`）寄 Email +（有綁定者）Telegram 提醒填表。靠 `orders.feedback_reminded_at` + 24–72h 時間窗防重複/防歷史洪水。
- `FEEDBACK_FORM_URL` 已設在正式機 .env。

**TA 已鎖定 = 第一次接觸人類圖的人**
- 封面應寫「給第一次接觸人類圖的你」。

**報告內容改版待辦（核心，尚未動工）**
墨客（skills 來源）與初學者 Peggy 的回饋彙整：
- 太「AI」：充斥「不是…不是…而是…」句型、各層不連貫、總結抽象 → 要去 AI 腔、上下文融會貫通
- 術語太「人類圖小圈圈」、高濃縮句要「稀釋稀釋再稀釋」（例：「超越邏輯分析的知曉…個體性的洞見」要更白話）
- Peggy：字太多有壓力、專業名詞不懂 → 建議**短主報告 + 補充**（補充可由 Telegram bot 諮詢承接，待封測 Q20 驗證）
- 改的是 `skills/report.md`（runtime 載入的報告生成 prompt）

**報告品質已做的兩大改善（2026-06-04）**
1. **RAG 知識庫**（見 [[project_knowledge_base]]）：產報告/諮詢注入精確知識＋墨客語氣範本，治拼貼感
2. **語氣引擎 skill**：`skills/human_design_voice.md`（聲音DNA＋六條鐵律＋禁巴納姆空話），由 `Client` 注入產報告/chat/諮詢三處 system prompt，直接治「太AI/繞口」

下一步：封測回收後，把問卷結果轉成可行動改版清單。相關踩坑見 [[reference_mpdf_skill]]。
