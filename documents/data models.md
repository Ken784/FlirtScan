## **曖昧分析指標**

### **雷達圖** 

1. 情緒投入度（Emotional Engagement）  
   曖昧的本質是「在意」。一個人是否願意展示情緒（開心、生氣、擔心、心疼、撒嬌），是判斷曖昧最核心的指標之一。

   NLP 評分依據  
* 情緒性詞彙（生氣、難過、可愛、緊張、心疼…）  
* 表達脆弱、羞愧、自責、在乎的句型（如「我竟然忘記回你」）  
* 情緒表情符號（🥺😢😍😳）  
* 感嘆詞（欸、啦、喔、嗚嗚…）  
* 負面情緒是否由對方安撫（= 情緒依賴）  
* 情緒強度（比喻、語氣詞、反覆強調）

2. 語氣親密度（Intimacy of Tone）  
   曖昧關係裡，語氣會自然變得輕、軟、甜、有點像講悄悄話。親密語氣往往比字面內容更有指標性。

   NLP 評分依據  
* 親暱稱呼（你呀、小笨蛋、baby、你幹嘛啦）  
* 軟化語氣的助詞（啦、呀、欸、小、一下下、啾）  
* 隱含肢體語言（抱、摸頭、啾、靠過來…）  
* 對方語氣是否像「對一個特別的人說」  
* 句子是否溫柔 vs. 中性 vs. 生硬

3. 玩笑 / 調情程度（Playfulness / Flirtation）  
   曖昧的「味道」最常來自玩鬧、互相挑釁、半真半假的暗示。玩笑常常是調情的包裝。

   NLP 評分依據  
* 撩人/曖昧玩笑（跪、傻瓜、給我啾一口…）  
* 性張力 or 軽度戲謔（你想怎麼補償？）  
* 角色扮演（你跪下我原諒你）  
* 過度可愛化語氣（啊啊啊可愛死了）  
* 雙關語、含蓄暗示

4. 回覆積極度（Responsiveness / Engagement）  
   「是否想跟你聊天」是判斷曖昧的重要基礎。積極回覆＝願意投入。

   NLP 評分依據  
* 回覆速度（從截圖時間推估），若無可靠的逐則訊息時間戳，降低此維度權重  
* 回覆長度（不是敷衍）  
* 是否主動開話題  
* 是否接住對方情緒  
* 是否提供資訊 vs. 單純應付  
* 是否結束對話 or 讓對話延續

5. 互動平衡度（Interaction Balance）  
   健康的曖昧通常是 **雙向的**。不是單方面撩、或單方面敷衍。互動平衡度越高，曖昧越「穩定互相」。

   NLP 評分依據  
* 雙方是否都有主動（不是單方話多）  
* 對話的 “能量量級” 是否相當  
* 語氣回應是否互補（對方撒嬌 → 你安撫）  
* 回覆情緒強度是否平衡  
* 玩笑是否雙向  
* 調情是否雙向（不是單方）


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

class AnalysisRequest {
  final String userId;
  final String imageBase64;    // 壓縮後的對話截圖 (Base64 String)
  final String language;       // App 當前語言 (zh-TW)
}


###B. 雷達圖維度 (RadarMetric)###

class RadarMetric {
  final double score;       // 0-10 分
  final String description; // 該維度的具體評語
  
  RadarMetric({required this.score, required this.description});
}


###C. 完整分析結果 (AnalysisResult) - 需支援 JSON 序列化以存入本地###

class AnalysisResult {
  final String id;
  final DateTime createdAt;      // 建立時間 (用於歷史排序)
  final String partnerName;      // 對方名稱 (由 LLM 推測或顯示為 "對方")
  
  // 雷達圖五維度
  final RadarMetric emotional;
  final RadarMetric intimacy;
  final RadarMetric playfulness;
  final RadarMetric responsive;
  final RadarMetric balance;
  
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

##