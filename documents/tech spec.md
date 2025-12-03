技術堆疊 (Tech Stack)

- App Framework: Flutter (iOS 優先, Android 兼容)
- Language: Dart
- State Management: Flutter Riverpod (2.x) 搭配 Code Generation
- Navigation: GoRouter
- Backend: Firebase (Auth, Firestore, Cloud Functions)
- AI/ML:
    - Client-side OCR: google_mlkit_text_recognition
    - Server-side NLP: OpenAI API (透過 Cloud Functions 呼叫)

- Ads: google_mobile_ads
- Local Storage: shared_preferences 或 hive (用於儲存歷史紀錄)
- I18n: flutter_localizations (預設 zh_TW)

架構與分層 (Architecture)

- Presentation（Widgets/Pages）  
- Application（UseCases / Controllers）  
- Domain（Entities / Repositories Interfaces）  
- Infrastructure（Firebase/HTTP/Ads/Analytics 實作）  
- 透過 Riverpod + ProviderScope 注入依賴（DI），Repository/Service 以 interface + 實作分離  

錯誤與重試策略 (Errors & Retry)

- 定義錯誤型別：NetworkError / AdsError / OcrError / OaiError / ValidationError  
- 對可重試的操作（廣告載入、函式呼叫）採指數退避（exponential backoff + jitter）  
- 端上顯示人性化錯誤，並上報 error_occurred 事件（含分類/狀態碼）  

Analytics 事件

- analysis_start, ocr_complete, ad_load/ad_show/ad_earn, advanced_unlock, share_image, error_occurred  
- 重要屬性：modelVersion, chatAppType, locale, processingTimeMs, sentenceCount, isGroupFlag  

i18n 與內容生成

- App 文案使用 flutter_localizations + 自有 ARB 多語；字型與 emoji fallback  
- Prompt 模板多語版本，根據 locale 注入；CJK 分詞與標點保留策略  
- 目前 LLM 輸出語言不強制；若用戶選擇固定語言可於後端切換模板  

廣告與合規

- google_mobile_ads：預設 NPA（非個人化）；Rewarded Ads  
- UMP（GDPR/CCPA）與 iOS ATT 流程整合；未同意時限制資料收集  
- AdMob SSV：Rewarded 後端核銷，回傳 token 與驗證簽章  
- App Check 啟用，限制 Functions 訪問；速率限制與設備級配額  

後端（Firebase + Cloud Functions）

- Callable Functions：/analyzeText、/redeemAd（驗證 SSV）  
- 原文處理：對話原文（含人名）直接送 LLM 分析；不做 PII 遮罩與摘要；僅在函式執行期駐留記憶體，不做持久化  
- 超長處理：採分段滑窗（sliding window）全量分析，確保上下文一致性；UI 可挑選關鍵句展示，但 LLM 分析以原文為準  
- 快取與成本：以 ocrHash 做去重快取（避免重複分析）；可分段並行處理以降低延遲  
- 安全：Moderation 旗標（bullying/sexual/profanity），對輸出做溫和化處理（不影響原文傳遞）  
- 日誌與版本：記錄 modelVersion、processingTimeMs、錯誤碼，便於回溯與優化  