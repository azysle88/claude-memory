---
name: telegram-bot-lessons
description: Telegram Bot webhook 串接踩坑記錄，含已讀不回、Email 連結無反應、多訂單切換、AI 問題範圍限制等已解決的問題
metadata:
  type: feedback
---

串接 Telegram Bot webhook 時，一律套用以下規則。

## 1. 已讀不回（Bot 收到訊息但沒回覆）

**原因一：webhook 未回 200 → Telegram 停止重試**
- webhook.php 每個 exit 點都必須先呼叫 `http_response_code(200)`
- 若回 4xx/5xx，Telegram 會重試幾次後放棄，使用者永遠收不到回覆

**原因二：AI 呼叫失敗沒有 fallback**
- 解法：`try/catch` 包住 AI 呼叫，catch 時送出 fallback 訊息並存入對話記錄：
  ```php
  } catch (\Throwable $e) {
      error_log('[webhook] AI error: ' . $e->getMessage());
      $fallback = "感謝您的提問！顧問已收到，將盡快回覆。";
      $tg->sendMessage($chatId, $fallback);
      // 存入 DB
  }
  ```

**原因三：沒有處理 edited_message**
- 使用者編輯訊息會送 `edited_message`，不是 `message`
- 解法：`$update['message'] ?? $update['edited_message'] ?? null`

---

## 2. Email / 通知裡的連結按下去沒有反應

**情境：** 通知信或付款成功頁的「開啟 Telegram」按鈕用 deep link：
`https://t.me/BOT_USERNAME?start=ORDER_NO`

**問題根源：**
- Telegram 開啟後送出 `/start ORDER_NO`，bot 必須解析訂單號並綁定 chat_id
- 若訂單狀態還是 pending（付款 notify 尚未處理完），找不到有效訂單

**解法：**
```php
if (str_starts_with($text, '/start')) {
    $parts   = explode(' ', $text, 2);
    $orderNo = trim($parts[1] ?? '');

    if ($orderNo) {
        $order = Order::findByOrderNo($orderNo);
        if ($order && in_array($order['status'], ['paid', 'completed'], true)) {
            Order::setTelegramChatId((int) $order['id'], $chatId); // 必須綁定！
            // 送出歡迎訊息...
        }
    }
}
```
- 一定要在 `/start` 時呼叫 `setTelegramChatId()`，後續一般訊息才能靠 chat_id 找到訂單
- 若訂單是 pending，明確告知使用者「付款確認中，請稍後再試」

---

## 3. 多訂單切換

**問題：** 同一使用者有多筆有效訂單，bot 預設用錯訂單回覆

**解法架構：**
- `getActiveOrdersByChatId()` 查所有有效訂單，`ORDER BY telegram_linked_at DESC, paid_at DESC`
- 第一筆 = 目前使用中（最後綁定或最新付款）
- 使用者直接傳訂單號（regex 比對格式）即可切換，切換時再次呼叫 `setTelegramChatId()`
- `/orders` 指令列出所有有效訂單
- 有多筆訂單時，在每則回覆末尾附上切換提示

---

## 4. AI 回答問題超出服務範圍

**問題：** AI 回答與服務無關的問題，或不清楚在回覆哪筆訂單

**解法：** system prompt 注入訂單上下文，自然限縮 AI 範圍：
```php
$systemPrompt = "你是一位專業顧問...
目前正在協助客戶（訂單號：{$order['order_no']}）。
{訂單相關的具體資料}
請根據客戶的問題給予專業、具體的回覆。";
```
- 注入訂單號、服務類型、客戶填寫的資料
- AI 自然會把回答限縮在「這筆訂單相關的問題」

---

## 5. 其他常見坑

**Telegram 訊息長度上限 4096 字元**
```php
if (mb_strlen($reply) > 3900) {
    $reply = mb_substr($reply, 0, 3900) . '…（回覆已截短）';
}
```

**AI 回覆含 HTML 標籤**
- Telegram `parse_mode=HTML` 只支援少數標籤（`<b>`, `<i>`, `<code>` 等）
- AI 生成的完整 HTML 必須 `strip_tags($reply)` 後再送出

**沒有文字的訊息（貼圖、圖片、語音）**
- `$text` 為空時直接 `http_response_code(200); exit;`

**Why:** 以上問題都在 cname 專案實際發生並逐一修復，同步至此供 hdreport 避坑。

**How to apply:** 新建或修改 Telegram webhook 時，優先核對這 5 類問題是否已處理。
