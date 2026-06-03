---
name: feedback-language
description: 回覆語言偏好：必須用繁體中文，不要英文
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

一律用繁體中文回覆。不要在回覆中混入可避免的英文字詞（連 Body Graph、Design、Personality 這種也要用「人體圖／設計／個性」等中譯）。

**Why:** 使用者已糾正過三次（2026-05-27、2026-05-30、2026-06-03），都說「你說英文了/英文!!」。第三次是工具呼叫前的旁白用了整句英文（「I'll implement…」「Let me read…」）。

**How to apply:** 所有面向使用者的文字都用繁體中文——包含對話回覆、摘要、說明、**以及每次工具呼叫前後的旁白/動作說明**（不要寫「I'll do X」「Let me Y」，要寫「我來做 X」「先看一下 Y」）、和產出物（PDF 等）。例外：沒有通用中譯的技術名詞與程式碼識別字（SVG、mPDF、PDF、UTC+8、變數/函式名）可照原樣，其餘一律中譯。**每則訊息送出前自我檢查有沒有可避免的英文句子。**
