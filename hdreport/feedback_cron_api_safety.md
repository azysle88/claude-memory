---
name: feedback-cron-api-safety
description: cron / async worker 呼叫付費 API（Claude、OpenAI 等）的必套安全規則，避免 runaway loop 燒爆預算
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

任何「cron / async worker 撈待處理任務 → 呼叫付費 API → 寫 DB」的組合，一律套以下規則。違反任何一條都可能變成無限循環燒錢機器（[[project-hdreport]] 在 2026-05-22 ~ 2026-05-26 因缺這些防護燒掉約 US$280）。

**重要**：2026-05-28 已收到 Anthropic 正式回覆，**$280 退款請求被拒**。理由：所有 API consumption 不分原因（含 misconfig / automation bug / pre-launch testing）一律 non-refundable。預防永遠比事後爭取重要 → 部署前必跑 checklist。

## 必套規則

**狀態機要有「進行中」和「永久失敗」兩個終態，不能只有「成功 / 失敗回到待處理」**

```
pending → claimed/generating → success（終態）
                            → failed_permanent（終態，超過重試上限）
                            → pending（重試，attempts +1）
```

**Why:** 失敗回到 pending 是「重試」，永遠不寫終態就是「無限循環」。Runaway loop 本質就是「失敗時忘記寫終態」。

**How to apply:** DB 加 `status` enum 含這些值，加 `attempts INT DEFAULT 0` 欄位。`generate()` 開頭原子性 claim（UPDATE ... SET status='generating' WHERE status='pending' AND attempts < MAX），失敗時 catch 內 attempts+=1，達上限就 markPermanentFailed。

---

**Cron 撈待處理的 WHERE 一定要含 `attempts < MAX_ATTEMPTS`**

**Why:** 即使狀態機有 bug 沒寫終態，這條 SQL 也會阻止超過 N 次後繼續打 API。是「最後一道防線」。

**How to apply:** `SELECT ... WHERE status = 'pending' AND attempts < 3`。MAX 設 3 就好，給暫時性錯誤的緩衝，又限制最壞 cost = 3× per task。

---

**長時間 API 呼叫（>30s）後，DB 連線要重連**

**Why:** MySQL `wait_timeout` 預設 28800s 但共享主機常設成 60-180s。Claude API 生成 2-3 分鐘期間 DB 連線閒置 → server 主動斷 → 後續 INSERT 拋 SQLSTATE 4031 / 2013。

**How to apply:** `Database::reconnect()` 在 API 呼叫之後、寫 DB 之前呼叫一次。或乾脆把 DB 連線開在 API 之後（API 結束才需要 DB）。

---

**catch block 必須更新訂單狀態，不能只 `error_log` 就 return**

**Why:** 這是 [[project-hdreport]] 那個 bug 的直接成因。catch 裡 `error_log() + return false` 沒碰 DB → status 不變 → cron 再撈 → 再失敗 → 無限循環。

**How to apply:** catch 內一定要呼叫 `releaseForRetry()` 或 `markPermanentFailed()`。catch 內的 DB 寫入也要包 try/catch（DB 完全掛時不要拋出去），失敗就 log，依賴 cron 的「卡 generating 超過 N 分鐘自動回收」機制兜底。

---

**Worker 崩潰恢復：卡在 `generating` 超過合理時間要自動回收**

**Why:** Worker crash 後訂單會永遠卡在 `generating`，cron 又不撈這狀態，造成漏單。

**How to apply:** cron 開頭加：
```sql
UPDATE orders SET status='pending'
WHERE status='generating' AND last_attempt_at < NOW() - INTERVAL 10 MINUTE
```
attempts 不重置（每次 claim 都算一次嘗試，crash 也是一種失敗）。

---

**部署前必設 spend limit + email alert**

**Why:** 程式再怎麼防護，bug 永遠可能逃出去。API provider 的硬上限是最後一道防線，事後也救不回但能止血。

**How to apply:**
- Anthropic Console → Settings → Limits → Monthly spend limit（設成你能接受的最壞情況）
- 設 spend threshold alerts（例如 $5、$10、$20 三段）→ email 通知
- 把 spend limit 寫進部署 checklist，沒設不准上線

---

**用量 log 表 + 每日異常告警**

**Why:** 純靠 Console 通知是「事後」，且通常設定 spend threshold 才會觸發。應用層要有自己的 metrics 才能在小時級而非天級時間發現問題。

**How to apply:** 加 `api_usage_log` 表（時間、endpoint、tokens、status、cost），每次 API 呼叫前後寫一筆。每日 cron 撈昨日統計送 Telegram / Email；同時 cron 內 inline 查詢 `attempts >= 2` 的訂單即時告警（[[project-hdreport]] 的 Layer 4）。

---

## 部署 checklist（cron + 付費 API 專案通用）

- [ ] DB 有 `attempts`、`last_attempt_at` 欄位
- [ ] status enum 含 `generating` / `failed_permanent` 終態
- [ ] cron WHERE 含 `attempts < MAX`
- [ ] `claim` 動作用原子性 UPDATE，不用 SELECT-then-UPDATE
- [ ] 長 API 呼叫後重連 DB
- [ ] catch 一定更新 status，且自己包 try/catch
- [ ] Stale worker 回收邏輯
- [ ] Anthropic Console / OpenAI spend limit
- [ ] api_usage_log 表 + 每日 digest
- [ ] 異常告警（Telegram / Email）
