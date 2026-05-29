---
name: reference-mpdf-skill
description: mPDF + Claude HTML→PDF 報告生成踩坑指南位置，可複製到其他專案
metadata: 
  node_type: memory
  type: reference
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

完整的 mPDF PDF 報告生成踩坑筆記在：

`C:\projects\hdreport\skills\mpdf_pdf_generation.md`

涵蓋：
- mPDF CSS 支援缺口（clamp/vw/flex/background-clip/animation 等）
- cid0tc 字體缺字補丁表（全形括號、✦ 等）
- 字體大小必須用 pt+!important 而非 rem
- 寬度與居中靠 `<table align width>` 而不是 CSS
- Claude max_tokens 與 HTTP timeout 對應關係（24K → 600s）
- Prompt caching 啟用方式與 cache token 記錄
- PHP heredoc 內 `<?= ?>` 不會被執行的坑
- OPcache 對 cron 的影響
- prepareForMpdf 完整處理順序
- 14 條黃金原則

**未來其他專案做類似報告功能時**：直接 cp 此檔到該專案 skills/，配合 Generator.php 範本即可省下大量摸索時間。
