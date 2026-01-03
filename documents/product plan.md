## **💘 FlirtScan曖昧解碼器 MVP 產品藍圖**

### **🎯 一句話定位**

一款讓你上傳對話截圖、分析曖昧指數、並產出可分享結果的娛樂型 App。

---

## **🧩 核心體驗流程**

1. **主畫面**  
   * CTA：「上傳對話截圖」  
   * 上傳以後，可刪除重新上傳。  
   * 按下「開始分析」的按鈕進入觀看廣告階段  
2. **觀看廣告階段**  
   * Rewarded Ad 播放中，需顯示廣告時間倒數  
   * 同時背景執行 OCR 與 NLP 分析  
   * Ad上方一個小空間，動畫提示：「正在揣摩他的心思...💭」  
3. **結果頁面（重點畫面）**  
   * **主結果區**：曖昧指數分數（0\~10）+ 雷達圖  
     * 雷達圖六向度：  
       1. 撩撥張力（Tension）  
       2. 自我揭露（Disclosure）  
       3. 關係動能（Momentum）  
       4. 專屬特權（Exclusivity）  
       5. 誘敵導引（Baiting）  
       6. 心理防禦（Defense）  
     * 分數顯示需要延遲一點時間，並用動畫，營造期待的感覺。  
     * 雷達圖顯示也需要動畫  
   * **總結**：

      「他明顯在試探妳的反應，語氣裡帶一點期待 😏」

   * **語氣洞察**：

      「那句『哈哈哈』不是尷尬，而是掩飾緊張。」

   * **梗化結語（可分享句）**：

      「曖昧就像 Wi-Fi，訊號強但不一定連得上。」

   * **按鈕1**：「進階逐句分析」

   * **按鈕2**：「截圖」，以 Flutter 將結果頁內容渲染為可捲動畫布，再輸出單張長圖。

4. **逐句分析**  
   * 會播放Rewarded Ad  
   * Ad上方一個小空間，動畫提示：「讓我分析你們細微的互動…」  
   * 最後會每一句顯示分析結果，要包括**背後含意**以及**曖昧指數**；逐句引用**原文**內容（不做摘要、不遮人名）。例如：

      **1️⃣ “幹……我快氣到哭 全部都老一滴血輸掉欸 😢”**

      **→ 背後含義：**

      對方在抱怨輸遊戲、情緒很真實，語氣放鬆像在和熟人撒嬌。

      **→ 曖昧指數：★★☆☆☆☆☆☆☆☆（20%）**

      還算中性，偏朋友語氣，不過願意表達脆弱情緒，代表信任感。  
---

      **2️⃣ “妳要去吃飯時我已經吃飽繼續工作為🥺”**

      **→ 背後含義：**

      有一點「報備＋小抱怨」的感覺，像在暗示「妳不在我還在忙」，帶有情緒溫度。

      **→ 曖昧指數：★★★★☆☆☆☆☆☆（40%）**

      這句帶一點關心與「你在我生活裡有存在感」的意味。

   * 如果用戶上傳的對話太長，不重要的對話就跳過，最多顯示20句關鍵對話即可

5. **分析記錄頁面**  
   * 本地儲存一個標記 (Flag)，記錄用戶是否已為該次分析解鎖了內容。如果已解鎖，則從記錄頁面重新查看時**無需再次觀看廣告**  
   * 使用 shared_preferences 儲存分析歷史（JSON 格式，時間倒序排列）  
   * AdMob Server-Side Verification（SSV）規劃中，目前未實作；App 端旗標作為解鎖狀態快取  
   * 可刪除分析記錄（支援重試機制處理競態條件）  
   * 歷史列表以對方名稱（partnerName）命名，便於用戶辨識  
6. **錯誤訊息**  
   * 如果用戶上傳的截圖不是一般訊息對話，不進行分析，跳出錯誤訊息「抱歉，請上傳**一般訊息對話**截圖，我們無法分析非對話圖片喔！ 」  
   * 如果用戶上傳的截圖是多人對話，不進行分析，跳出錯誤訊息「抱歉，本功能僅支援**一對一**對話分析，請勿上傳多人群組對話截圖！ 」 
   * 網路不通，無法透過LLM分析時，不播放廣告，顯示「沒有網路，請連線後重試」  
7. **介面語言**  
   * 介面語言需提供英文、繁體中文、日文、韓文、西班牙文。但是LLM生成的內容語言由LLM決定，不需要強制定義

---

## **⚙️ 系統模組分層**

### **前端 (App)**

* 跨平台(iOS, Android), 用Flutter開發  
* 圖片處理：使用 image_picker 選取圖片，flutter_image_compress 壓縮並轉換為 Base64  
* OCR 圖片文字擷取：**後端使用 OpenAI Vision API (gpt-4o-mini) 同時進行 OCR 識別與對話分析**（非客戶端 OCR）  
* 狀態管理：使用 Flutter Riverpod (StateNotifierProvider) 管理分析狀態、歷史記錄、錯誤狀態  
* 路由：使用 GoRouter 進行頁面導航（WelcomePage, HomePage, ResultPage, ResultSentencePage, HistoryPage）  
* 情緒/語氣分析視覺化（雷達圖、分數動畫，使用 fl_chart）  
* Rewarded Ad 播放與控制（google_mobile_ads，分為 startAnalysis 和 advancedAnalysis 兩種類型）  
* 分享結果截圖產生器（screenshot_service，使用 share_plus）

### **後端** 

* 使用 Firebase Cloud Functions（TypeScript）  
* OCR 與 NLP 分析：使用 OpenAI Vision API (gpt-4o-mini) 同時進行圖片文字識別與對話分析  
* Cloud Functions：`analyzeConversation` - 接收 Base64 圖片，調用 OpenAI Vision API，返回結構化分析結果  
* 對話原文（含人名）會傳至 Cloud Functions 供 LLM 分析；僅於處理期間駐留記憶體，不做持久化儲存  
* App 端保留本地歷史（shared_preferences，JSON 格式）；後端不保留任何用戶數據  
* 報表與 Analytics：規劃中（目前未實作）  
  * 規劃項目：用戶下載後分析對話的頻率、一般分析與逐句分析的廣告統計、分析用戶的平均對話長度、截圖率等

## ⛑️ **開發順序**

- MVP先繁體中文，之後再上其他多國語言，但一開始架構就要規劃好  
- iOS先，後Android


## **🔒 合規與廣告政策**

- 僅供娛樂用途：結果為機器推估，可能有誤差，請勿作為情感建議  
- 隱私：對話內容分析後，僅本地儲存（shared_preferences，可一鍵刪除）  
- 同意與隱私管理：
  - Google UMP（User Messaging Platform）：已實作，使用 AdConsentManager 處理 GDPR/CCPA 授權流程  
  - iOS ATT（App Tracking Transparency）：規劃中（目前未實作）  
- 廣告：使用 Rewarded Ad（google_mobile_ads），分為 startAnalysis 和 advancedAnalysis 兩種類型  
- AdMob SSV（Server-Side Verification）：規劃中（目前未實作 redeemAd 函數）  
- 安全過濾：規劃中（目前未實作 Moderation 旗標）  

## **📈 Analytics 事件**

- 目前未實作 Analytics 追蹤（規劃中）  
- 規劃事件：
  - analysis_start（開始分析）  
  - ocr_complete（OCR 完成，但由於 OCR 在後端執行，此事件需要調整定義）  
  - ad_load / ad_show / ad_earn（廣告載入/顯示/獲得獎勵）  
  - advanced_unlock（逐句分析解鎖）  
  - share_image（分享長圖）  
  - error_occurred（錯誤，附錯誤型別與狀態碼）  
- 規劃屬性：modelVersion, chatAppType, locale, processingTimeMs, sentenceCount, isGroupFlag  


