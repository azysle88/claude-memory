---
name: feedback-php-pdo-pitfalls
description: PHP PDO 在 ATTR_EMULATE_PREPARES=false 模式下的常見坑（named param 重用、long-idle 斷線等）
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

PHP PDO 預設關閉 prepares emulation 比較安全，但會踩到以下坑。

## 必避坑

**同一個 named parameter 不能在一個 query 裡用兩次**

```php
// 會炸：SQLSTATE[HY093] Invalid parameter number
$stmt = $pdo->prepare(
    'INSERT INTO t (a, b) VALUES (:x, :y)
     ON DUPLICATE KEY UPDATE b = :y'   // :y 在 INSERT 和 UPDATE 都用 → 拋例外
);
$stmt->execute([':x' => 1, ':y' => 'hello']);
```

**Why:** PDO emulate=false 用真正的 MySQL prepared statement，每個 placeholder 是獨立 slot，不會自動展開重用。emulate=true 模式才會（emulation 用字串取代）。

**How to apply:** 重複用同一個值時，用不同 placeholder 名字，execute 時兩個都傳：
```php
'INSERT INTO t (a, b) VALUES (:x, :y)
 ON DUPLICATE KEY UPDATE b = :y_upd'
$stmt->execute([':x' => 1, ':y' => 'hello', ':y_upd' => 'hello']);
```

或 MySQL 8.0.19+ 用 alias 語法：
```php
'INSERT INTO t (a, b) VALUES (:x, :y) AS new
 ON DUPLICATE KEY UPDATE b = new.b'
```

[[project-hdreport]] 的 webhook 500 就是這個坑（Bot.php loadContext 用 `:username` 兩次）。

---

**`LIMIT :n` 必須用 `bindValue(..., PDO::PARAM_INT)`，不能用 execute() 的關聯陣列**

```php
// 會炸：MySQL 拒絕 LIMIT 'string'
$stmt = $pdo->prepare('SELECT * FROM t LIMIT :n');
$stmt->execute([':n' => 5]);  // 5 變字串 '5'
```

**Why:** emulate=false 下，execute() 預設把所有值當字串綁定。LIMIT 必須是 int literal。

**How to apply:**
```php
$stmt = $pdo->prepare('SELECT * FROM t LIMIT :n');
$stmt->bindValue(':n', 5, PDO::PARAM_INT);
$stmt->execute();
```

---

**長時間操作後 DB 連線會被 server 斷掉**

**Why:** MySQL `wait_timeout` 共享主機常設 60-180s。PHP 持有的 PDO 連線閒置超過就被 server kill，下次 execute() 拋 SQLSTATE 4031 / 2013。

**How to apply:** 詳見 [[feedback-cron-api-safety]]，重點是長 API 呼叫後重連 DB。

---

**transactional INSERT-after-SELECT 必須包 transaction，否則有 race condition**

例如「先 SELECT 看是否存在，不存在則 INSERT」，兩個 request 同時進來會雙寫。

**How to apply:** 用 `INSERT ... ON DUPLICATE KEY UPDATE` 或 `INSERT IGNORE`，靠 unique index 防止。**不要**用 SELECT-then-INSERT 模式。

---

**fetchAll() 大表會吃光記憶體**

emulate=false 下 fetchAll 把整個結果集一次拉進來。大表用迴圈：
```php
while ($row = $stmt->fetch()) { ... }
```

或加 `LIMIT` / OFFSET 分頁。
