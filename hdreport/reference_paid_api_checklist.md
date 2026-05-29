---
name: reference-paid-api-checklist
description: 付費 API 專案部署前的完整 checklist 位置，含 schema/code patterns/cron/monitoring/演練
metadata: 
  node_type: memory
  type: reference
  originSessionId: 9bb40ec7-6995-40cb-81c3-855d585d8994
---

完整的「付費 API 專案部署 checklist」在：

`C:\projects\hdreport\skills\paid_api_deployment_checklist.md`

涵蓋 6 個 phase：
- Phase 0: Console spend limit 與 alerts 設定
- Phase 1: DB schema（status enum / attempts / api_usage_log）
- Phase 2: Code patterns（原子性 claim、catch 更新 status、DB 重連、stale worker 回收、prompt caching）
- Phase 3: Cron 配置（WHERE attempts<MAX、stale 回收）
- Phase 4: 監控與告警（每筆 log、daily digest、即時告警）
- Phase 5: 部署前最終 checklist + **演練失敗驗證**
- Phase 6: 正式營運後例行確認

**配合既有 [[feedback-cron-api-safety]] 使用**：
- feedback_cron_api_safety = 規則與 why（原則性）
- paid_api_deployment_checklist = 可勾選的 actionable 清單（執行性）

新專案要接 Claude/OpenAI/任何付費 API 時，**先把這份 checklist 跑一遍**，避免重蹈 hdreport $280 學費（Anthropic 已確認不退款）。
