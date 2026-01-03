技術堆疊 (Tech Stack)

- App Framework: Flutter (iOS 優先, Android 兼容)
- Language: Dart
- State Management: Flutter Riverpod (2.5.1) 使用 StateNotifierProvider
- Navigation: GoRouter (13.2.2)
- Backend: Firebase (Firebase Core, Cloud Functions)
- AI/ML:
    - OCR: 後端使用 OpenAI Vision API (gpt-4o-mini) 進行圖片文字識別
    - NLP: OpenAI API (透過 Cloud Functions 呼叫) 進行對話分析

- Ads: google_mobile_ads (7.0.0)
- Local Storage: shared_preferences (2.2.2) 用於儲存歷史紀錄（JSON 格式）
- I18n: flutter_localizations (使用 ARB 檔案：app_zh_TW.arb, app_zh.arb)

架構與分層 (Architecture)

- Presentation（Widgets/Pages）：HomePage, ResultPage, ResultSentencePage, HistoryPage, WelcomePage
- Core（Models/Providers/Theme）：AnalysisResult, AnalysisProvider, HistoryProvider, LocaleProvider, ErrorProvider
- Services：AnalysisService, AdService, ImageService, StorageService, AdConsentManager, ScreenshotService
- Features（Repositories）：AnalysisRepository
- 透過 Riverpod + ProviderScope 注入依賴，使用 StateNotifierProvider 管理狀態  

錯誤與重試策略 (Errors & Retry)

- 定義錯誤型別：AnalysisException (AnalysisExceptionType: invalidImage, serverError, networkError, unknown)
- 廣告載入採用固定延遲重試（3秒，最多5次）
- 本地儲存操作採用重試機制（最多3次，50ms延遲）處理競態條件
- 端上顯示人性化錯誤訊息，錯誤透過 AnalysisState 的 errorMessage 傳遞  

Analytics 事件

- 目前未實作 Analytics 追蹤（規劃中）
- 規劃事件：analysis_start, ocr_complete, ad_load/ad_show/ad_earn, advanced_unlock, share_image, error_occurred
- 規劃屬性：modelVersion, chatAppType, locale, processingTimeMs, sentenceCount, isGroupFlag  

i18n 與內容生成

- App 文案使用 flutter_localizations + 自有 ARB 多語；字型與 emoji fallback  
- Prompt 模板多語版本，根據 locale 注入；CJK 分詞與標點保留策略  
- 目前 LLM 輸出語言不強制；若用戶選擇固定語言可於後端切換模板  

廣告與合規

- google_mobile_ads：Rewarded Ads（分為 startAnalysis 和 advancedAnalysis 兩種類型）
- UMP（User Messaging Platform）：使用 AdConsentManager 處理 GDPR/CCPA 授權流程
- 授權流程：初始化時請求授權資訊更新，只有在取得用戶同意後才初始化廣告 SDK
- iOS ATT 流程：規劃中（目前未實作）
- AdMob SSV（Server-Side Verification）：規劃中，目前未實作 redeemAd 函數
- App Check：規劃中（目前未啟用）  

後端（Firebase + Cloud Functions）

- Callable Functions：/analyzeConversation（分析對話截圖）
- OCR 與 NLP：使用 OpenAI Vision API (gpt-4o-mini) 同時進行圖片文字識別與對話分析
- 原文處理：對話原文（含人名）直接送 LLM 分析；不做 PII 遮罩與摘要；僅在函式執行期駐留記憶體，不做持久化
- 分析流程：
  - 使用 OpenAI Vision API 的 image_url 參數直接分析 Base64 編碼的圖片
  - LLM 同時執行 OCR 識別和對話分析，返回結構化 JSON 結果
  - 選出 3-8 句關鍵對話進行逐句分析（按圖片中從上到下的順序）
- 錯誤處理：檢查圖片是否為對話截圖（invalid_image_content），驗證必要欄位
- 日誌：記錄函數調用、OpenAI API 調用、處理時間、Token 使用量等資訊
- 模型：使用 gpt-4o-mini，temperature=0.3，max_tokens=4000，response_format=json_object
- 安全：規劃 Moderation 旗標（目前未實作）
- 快取：規劃 ocrHash 去重快取（目前未實作）  