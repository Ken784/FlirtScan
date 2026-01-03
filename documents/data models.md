## **曖昧分析指標**

### **雷達圖（六維度）** 

1. **撩撥張力（Tension）**  
   評估是否存在「火花」？調情、故意挑釁、反向操作。是否利用雙關、學術梗或角色扮演來進行心理拉扯。

   NLP 評分依據  
* 撩人/曖昧玩笑（跪、傻瓜、給我啾一口…）  
* 性張力 or 軽度戲謔（你想怎麼補償？）  
* 角色扮演（你跪下我原諒你）  
* 雙關語、含蓄暗示  
* 反向操作、故意挑釁

2. **自我揭露（Disclosure）**  
   評估是否願意展示私密情緒、分享非必要的瑣碎生活或個人弱點？

   NLP 評分依據  
* 情緒性詞彙（生氣、難過、可愛、緊張、心疼…）  
* 表達脆弱、羞愧、自責、在乎的句型（如「我竟然忘記回你」）  
* 情緒表情符號（🥺😢😍😳）  
* 感嘆詞（欸、啦、喔、嗚嗚…）  
* 分享私生活的細節  
* 負面情緒是否由對方安撫（= 情緒依賴）

3. **關係動能（Momentum）**  
   評估關係是否有向前推進的意圖（如：見面暗示、未來規劃、感情狀態試探）。

   NLP 評分依據  
* 是否主動開話題  
* 是否接住對方情緒並延續對話  
* 是否有見面暗示或未來規劃  
* 是否試探感情狀態  
* 是否結束對話 or 讓對話延續

4. **專屬特權（Exclusivity）**  
   評估是否建立了一種「只有我們懂」的氛圍，將其他人隔絕在外。例如：我們的祕密、我們的活動、經歷、我們才懂得的梗。

   NLP 評分依據  
* 是否建立專屬的梗或默契  
* 是否提及共同經歷或回憶  
* 是否將其他人隔絕在外  
* 是否創造「只有我們懂」的氛圍  
* 語氣是否像「對一個特別的人說」

5. **誘敵導引（Baiting）**  
   俗稱「做球」。是否主動製造被撩的機會、拋出容易接續的話題或顯示需求感。

   NLP 評分依據  
* 是否主動製造被撩的機會  
* 是否拋出容易接續的話題  
* 是否顯示需求感或期待  
* 是否在對話中「做球」給對方  
* 是否創造互動的機會

6. **心理防禦（Defense）**  
   識別「保護色」。是否在釋放張力後利用專業身分或玩笑掩飾真心。

   NLP 評分依據  
* 是否在釋放高張力訊號後立刻掩蓋  
* 是否用專業、玩笑或第三方話題掩飾  
* 是否使用「逃生門」機制  
* 是否在高階曖昧中表現防禦


### **曖昧指數 0–10**

**0 分｜完全無曖昧**

純資訊交換、零情緒、像客服對話。  
沒有任何多餘的互動或個人關注。

**1 分｜禮貌性的互動**

禮貌但僅止於此，沒有想延續話題的意圖。  
互動的長度與投入度都低。

**2 分｜輕微好感影子**

有些微友善，但仍然是一般朋友、同事的日常。  
偶爾會回你，但沒有主動性。

**3 分｜正常朋友互動**

開始有一些自然的關心或小玩笑。  
但這類訊號在一般友情中也很常見，不具曖昧性。

**4 分｜低度曖昧感**

會展現出更多關心、稍微個人化的內容。  
但仍可能只是善良或習慣，不算明確曖昧。

**5 分｜曖昧邊緣**

開始有潛在但不明顯的曖昧。  
對話節奏、關注度開始上升，但還不足以確定對方有意思。

**6 分｜明顯暖意**

開始主動聊天、維持對話、針對你個人本身有興趣。  
回覆速度與投入度明顯提升。

**7 分｜高度曖昧**

出現專屬感、特別在意、想要延續互動等訊號。  
語氣會更輕鬆、調皮、個人化。

**8 分｜強烈曖昧**

對方願意敞開個人情緒、分享私生活、把你當成重要對象。  
雙方開始有曖昧氛圍或情緒張力。

**9 分｜準告白狀態**

對話中已很明顯互相試探、暗示、想更靠近。  
甚至會出現半開玩笑的曖昧話語（例如：你怎麼這麼可愛）。

**10 分｜直球曖昧／明顯就是喜歡**

語氣、內容、互動全是濃度極高的好感。  
不只是曖昧，已接近明確的戀愛意圖。  
包含主動約你、想維持每天聯繫、明示你的重要性。

###

##

## 資料結構定義 (Data Models)

###A. 分析請求 (AnalysisRequest)###

注意：實際實作中，分析請求直接透過 Firebase Functions 的 `analyzeConversation` 函數發送，不單獨定義 Request 類別。請求參數包括：

* imageBase64: String - 壓縮後的對話截圖 (Base64 String)
* language: String - App 當前語言代碼（例如：'zh-TW'）


###B. 雷達圖維度 (RadarMetric)###

class RadarMetric {
  final double score;       // 0-10 分
  final String description; // 該維度的具體評語（至少 40 個字）
  
  RadarMetric({required this.score, required this.description});
}

###B-1. 雷達圖 (Radar)###

class Radar {
  final RadarMetric tension;      // 撩撥張力
  final RadarMetric disclosure;   // 自我揭露
  final RadarMetric momentum;     // 關係動能
  final RadarMetric exclusivity;  // 專屬特權
  final RadarMetric baiting;      // 誘敵導引
  final RadarMetric defense;      // 心理防禦
  
  Radar({
    required this.tension,
    required this.disclosure,
    required this.momentum,
    required this.exclusivity,
    required this.baiting,
    required this.defense,
  });
}


###C. 完整分析結果 (AnalysisResult) - 需支援 JSON 序列化以存入本地###

class AnalysisResult {
  final String id;
  final DateTime createdAt;      // 建立時間 (用於歷史排序)
  final String partnerName;      // 對方名稱 (由 LLM 推測或顯示為 "對方")
  
  // 雷達圖六維度
  final Radar radar;  // 包含六個維度：tension, disclosure, momentum, exclusivity, baiting, defense
  
  final double totalScore;       // 總分 (對應圖中的 9/10)
  final String relationshipStatus; // 關係狀態短語 (如: "準告白狀態", "純屬路人") - 對應圖中分數旁的文字
  final String summary;          // 總結 (包含 Bullet points)
  final String toneInsight;      // 語氣洞察
  final String wittyConclusion;  // 金句 (可選保留或用於分享頁)
  
  // 進階分析相關
  final List<SentenceAnalysis> sentences; // 逐句分析列表
  final String advancedSummary;  // 進階頁面底部的總結 (對應截圖紫色區塊)
  
  // 狀態標記
  final bool isAdvancedUnlocked; // 是否已解鎖進階分析 (看過廣告)
}


###D. 逐句分析 (SentenceAnalysis)###

enum Speaker { me, partner, unknown }

class SentenceAnalysis {
  final String originalText;     // 原始對話內容 (由 LLM 視覺辨識)
  final Speaker speaker;         // 發話者
  final String hiddenMeaning;    // 背後含意 (潛台詞)
  final int flirtScore;          // 1-10 星 (換算成 20%-100%)
  final String scoreReason;      // 分數說明

  SentenceAnalysis({
    required this.originalText,
    required this.speaker,
    required this.hiddenMeaning,
    required this.flirtScore,
    required this.scoreReason,
  });
}

###E. 歷史記錄項目 (AnalysisHistoryEntry)###

class AnalysisHistoryEntry {
  final AnalysisResult result;      // 分析結果
  final String? imageBase64;        // 對話截圖（可選，用於重新查看時顯示）
  
  AnalysisHistoryEntry({
    required this.result,
    this.imageBase64,
  });
}

##