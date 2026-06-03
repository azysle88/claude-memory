---
name: reference-newebpay-skill
description: 藍新金流完整實作範本的所在位置
metadata: 
  node_type: memory
  type: reference
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

完整可 copy 的實作範本存放於：

**`C:\project\hdreport\skills\newebpay.md`**（也在 GitHub `azysle88/hdreport` main branch）

包含：Newebpay.php 完整類別、checkout.php、notify.php、return.php、DB schema、.env 設定、測試信用卡號、上線切換清單。

新專案直接複製這份 skill，修改 `ORDER_PREFIX`（2碼英文）和 `ItemDesc` 即可使用。
套用前先讀 [[feedback-newebpay]] 確認規則都有遵守。
