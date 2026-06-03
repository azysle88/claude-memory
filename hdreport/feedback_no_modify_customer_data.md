---
name: feedback-no-modify-customer-data
description: 嚴禁竄改客戶原始輸入資料（如出生時間）；計算錯誤要從程式邏輯找原因
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 77219410-ece1-4e35-b3a6-12d3993f0814
---

絕對不可以為了讓計算結果「對」而去修改客戶在資料庫裡的原始輸入（出生日期、時間、地點等）。客戶輸入的值我們沒有權利說是錯的。

**Why:** 使用者嚴正指出「客戶輸入的值，我們沒有權利說是錯的，你這樣是修改原始資料」——竄改原始資料等於造假。先前我誤判客戶出生時間有誤、提議改 DB birth_time，被當場糾正。真正的根因是程式端（人類圖計算寫死 UTC+8，沒處理台灣 1979 歷史夏令時間 UTC+9），修程式而非改資料。

**How to apply:** 報告/計算結果與預期不符時，先懷疑程式邏輯、時區、演算法，到 [[project-hdreport]] 的計算流程找 bug；永遠不要動 orders 表的客戶原始欄位。
