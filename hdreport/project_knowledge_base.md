---
name: project-knowledge-base
description: docs/ 下兩個人類圖知識庫資料夾的內容與用途（報告改版素材）
metadata: 
  node_type: memory
  type: project
  originSessionId: 86d11d44-e7a6-42d8-97d7-f0c1c64f2c0c
---

報告改版（`skills/report.md`）要用的知識庫素材，2026-06-03 pull 進 `docs/`。**目前尚未消化進報告生成 prompt，是待辦。**

**`docs/人類圖_墨應系/`（486 檔 / 184 篇 vocus 文章）**
- **墨客本人**的文章與語氣（分類：人類大宗煩惱52、專業知識應用90、動情小品30、日常喜用神12）
- 子目錄：`_原始資料`（爬取原文）、`_結晶化`（已處理格式）、`_知識拓撲圖`
- **最關鍵用途**：墨客嫌目前報告「太 AI」，而這是他自己的文筆 → 是「去 AI 腔、像真人寫、為你而寫」的**目標語氣範本**

**`docs/亞洲人類圖學院/`（79 檔）**
- 系統化教學 + **標準術語**（顯示者/生產者/投射者… = 我們現在報告用的譯法）
- 子目錄：`_原始資料`、`_結晶化`
- 用途：知識正確性與標準術語來源

**注意**：兩邊術語有差異（亞洲學院 README 有對照表，例：Definition → 亞洲學院「定義」/墨應系「定義分割型態」）。報告統一用亞洲學院譯法（已在 Client.php 的中譯表固定）。

**RAG 已建好（2026-06-04，P0–P3 完成）**
- 規範：`docs/RAG_WIKI_STANDARD.md`；資料夾重整成 `docs/RAG/{canonical, voice, topology}`
- 向量庫：MySQL `rag_chunks` 表（migration 007），embedding 用 **Voyage**（voyage-3-lite，512 維），先 metadata SQL 過濾再 PHP cosine
- 已入庫（正式機）：canonical（亞洲學院）429 + voice（墨應系**結晶檔 `_結晶化`**）1015 = **1444 chunks**
- 程式：`src/Rag/{Chunker, EntityExtractor, EmbeddingClient, Retriever}`、`scripts/{rag_process, rag_search, rag_stats, run_sql}`
- 跑批在正式機 Linux（Windows 中文路徑 PHP 會壞）；source 檔上傳到 web root 外 `~/rag_src` 處理完即刪
- **VOYAGE_API_KEY 已設在正式機 .env**

**P4 待做**：把 `App\Rag\Retriever` 接到產報告 / 基核 / Telegram 諮詢三個 Agent（產報告用該圖的 hd 實體過濾召回 canonical+voice）。

**仍待優化**：canonical 4 篇重複未去重、結晶 Crystal Essence 可填 summary 欄、184 篇純 essay（風格模仿）未入庫。原報告改版方向見 [[project_beta_feedback]]。
