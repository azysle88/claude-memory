---
name: feedback-newebpay
description: 藍新金流（NewebPay）MPG 串接的正確實作規則與踩坑記錄，適用任何 PHP 專案
metadata: 
  node_type: memory
  type: feedback
  originSessionId: eaa50adc-d1bb-41f3-beaa-03c107947b36
---

串接藍新金流時，一律套用以下規則。完整實作範本在 [[reference-newebpay-skill]]。

## 必套規則

**MerchantOrderNo 不可用 UUID**
用 `PREFIX . str_pad($id, 8, '0', STR_PAD_LEFT)`（例如 `HD00000001`，10碼英數）。
**Why:** 藍新限制 30 碼英數，UUID 36 碼且含橫線 → 直接拒絕，付款跳轉即失敗。
**How to apply:** 每個專案定義 2 碼英文前綴（如 HD/CN/MS），從 DB auto-increment id 衍生，不另存欄位。

---

**RespondType 必須用 `'JSON'`，不用 `'String'`**
**Why:** String 模式解密後是 query string 格式，JSON 模式解密後是 JSON，現代實作統一用 JSON 更清楚；String 模式曾造成解析錯誤。
**How to apply:** `buildTradeData()` 裡設 `'RespondType' => 'JSON'`；`decryptCallback()` 用 `json_decode` 取 `$json['Result']`，不用 `parse_str`。

---

**TradeInfo 參數的數值型別統一用字串**
`Amt`、`TimeStamp`、`LoginType`、`EmailModify`、`CREDIT` 都傳字串。
**Why:** 部分藍新版本對 int 型別敏感，統一字串可避免奇怪的簽章驗證失敗。
**How to apply:** `'Amt' => (string)(int)$order['amount']`、`'TimeStamp' => (string)time()`。

---

**ClientBackURL 必填**
**Why:** 使用者點「取消付款」若無此欄位，會卡在藍新頁面無法跳回。
**How to apply:** 值等於 `$returnUrl`（與 ReturnURL 相同）。

---

**notify.php 不做同步報告生成**
**Why:** 報告生成耗時（Claude API 30-180s），callback 超時後藍新會重試，導致重複生成或藍新認定失敗。
**How to apply:** notify 只呼叫 `markPaid()`，立即回 `200`；報告生成交給 cron 每分鐘非同步掃描。

---

**return.php 必須做 POST → session → 302 → GET（PRG 模式）**
**Why:** 藍新以 cross-site POST 跳回，瀏覽器 SameSite=Lax 策略可能清掉 session；return 後使用者重整頁面會重送 POST，顯示狀態錯誤。
**How to apply:**
1. POST 進來：呼叫 `decryptReturn()`（不驗 hash，僅取 MerchantOrderNo）→ 存 session → 302 redirect 到 GET。
2. GET 進來：從 session 取 orderNo → `findByOrderNo()` 查 DB → 以 DB status 決定顯示（不信任 TradeInfo.Status）。
3. 若 gwStatus=SUCCESS 但 DB 還是 pending → 顯示「處理中」+ 10 秒 meta-refresh（等 notify cron 寫入）。

---

**return.php 不驗 TradeSha hash**
**Why:** return 頁面只做顯示，業務狀態以 DB 為準；hash 驗證在 notify.php 完成即可。驗兩次沒有意義，且在某些邊界情況會驗失敗。

---

**SHA256 TradeSha 驗證字串格式固定**
```
HashKey={hash_key}&{TradeInfo_hex}&HashIV={hash_iv}
```
**Why:** 順序錯（如 TradeInfo 放最後）會驗簽失敗，文件沒有清楚說明。
**How to apply:** 比對時兩邊都 `strtoupper()`。

---

**AES-256-CBC 必須手動處理 PKCS7 Padding**
**Why:** openssl 內建 padding 與藍新 block size 不匹配，產生錯誤密文。
**How to apply:** 使用 `OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING`，自己補/移除 PKCS7 padding（block size = 32 bytes）；加密後 `bin2hex()`，解密前 `hex2bin()`。

---

**藍新回傳 JSON 結構要展平**
藍新回傳：`{"Status": "SUCCESS", "Result": {"MerchantOrderNo": "...", ...}}`
**How to apply:** `array_merge(['Status' => $json['Status']], $json['Result'] ?? [])` → 統一用 `$data['MerchantOrderNo']` 存取，不用 `$data['Result']['MerchantOrderNo']`。

---

**findByOrderNo() 不需要額外 DB 欄位**
**Why:** orderNo 格式固定（2碼前綴 + 數字），可直接解析出 id，再 `WHERE id = ?` 查詢。
**How to apply:**
```php
public function findByOrderNo(string $orderNo): ?array
{
    if (!preg_match('/^[A-Z]{2}(\d+)$/', $orderNo, $m)) return null;
    $stmt = $this->db->prepare('SELECT * FROM orders WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => (int)$m[1]]);
    return $stmt->fetch() ?: null;
}
```
