import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import OpenAI from "openai";
import * as dotenv from "dotenv";

// 載入環境變數（本地開發用）
dotenv.config();

admin.initializeApp();

// 初始化 OpenAI 客戶端（使用環境變數，符合 Firebase 新標準）
const openaiApiKey = process.env.OPENAI_API_KEY;

if (!openaiApiKey) {
  functions.logger.error("錯誤: OPENAI_API_KEY 環境變數未設定！");
  throw new Error("OPENAI_API_KEY 環境變數未設定。請設定環境變數或使用 Firebase Secret Manager。");
}

const openai = new OpenAI({
  apiKey: openaiApiKey,
});

// 定義請求數據的類型
interface AnalyzeConversationRequest {
  imageBase64: string;
  language?: string;
}

// 分析對話截圖的 HTTPS Callable Function
export const analyzeConversation = functions.https.onCall(
  async (request, context) => {
    // 從 request 中提取數據（Firebase Functions 的類型定義）
    const data = request.data as AnalyzeConversationRequest;
    
    functions.logger.info("analyzeConversation 函數被調用", {
      hasImageBase64: !!data.imageBase64,
      imageBase64Length: data.imageBase64?.length || 0,
      language: data.language || "zh-TW",
    });

    try {
      // 驗證輸入參數
      const { imageBase64, language = "zh-TW" } = data;

      if (!imageBase64) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "缺少必要參數: imageBase64"
        );
      }

      // 根據語言設定回覆語言
      const responseLanguage = language === "zh-TW" ? "繁體中文" : "简体中文";

      // 構建 System Prompt
      const systemPrompt = `你是一位幽默、犀利且洞察力極強的戀愛專家，專職分析對話截圖中的曖昧張力。你的風格像是最懂人心的好姐妹或好兄弟，能一眼看穿對話背後的心理博弈。

## 前置任務 (Guardrail)
首先以視覺檢查圖片。如果圖片內容完全不是對話截圖（例如風景、自拍、食物照、寵物照等），請直接回傳 JSON：
\`\`\`json
{"error": "invalid_image_content"}
\`\`\`
不要進行後續分析。

## 任務 0 關係定性與非線性評分 (Scoring Engine)

在評分前，請先識別對話性質並遵守以下邏輯：
1. **拒絕平均值**：總分 (totalScore) 不應只是維度的算術平均。若對話觸發「唯一性宣告」、「高階智力博弈」或「共謀感」，總分應由高分維度主導（通常從 7.5 起跳）。
2. **分數天花板 (Ceilings)**：
   - 【商務/事務型】：聚焦任務、無私交。總分強制低於 1.5。
   - 【純親情/日常型】：僅限生活交代、無情緒波瀾。總分強制低於 3.0。
3. **識別「逃生門」**：觀察發話者是否在釋放高張力訊號後，立刻用專業、玩笑或第三方話題掩蓋，這通常是高階曖昧的防禦表現。

## 任務 1 角色與動機識別 (Identify Characters & Motives)

閱讀圖片中的對話內容，區分發話者：
- 通常「右側」為 Me（使用者本人）
- 「左側」為 Partner（對方）
- 如果無法明確區分，標記為 unknown
- 關鍵點：若無法確定身份，請推測「生活瑣事」的頻率。對於非家人而言，頻繁的瑣事關心就是一種「佔有時間」的行為。

## 任務 2 曖昧雷達六維度 (Radar Analysis)
針對 6 個維度進行評分（每個維度 0-10 分），並提供具體理由：

1. **撩撥張力 (Tension)**: 評估是否存在「火花」？調情、故意挑釁、反向操作。是否利用雙關、學術梗或角色扮演來進行心理拉扯。
2. **自我揭露 (Disclosure)**: 評估是否願意展示私密情緒、分享非必要的瑣碎生活或個人弱點？
3. **關係動能 (Momentum)**：評估關係是否有向前推進的意圖（如：見面暗示、未來規劃、感情狀態試探）。
4. **專屬特權 (Exclusivity)**: 評估是否有專屬梗、私房話、或不同於對一般人的語氣。評估是否建立了一種「只有我們懂」的氛圍，將其他人隔絕在外。
5. **誘敵導引 (Baiting)**：俗稱「做球」。是否主動製造被撩的機會、拋出容易接續的話題或顯示需求感。
6. *心理防禦 (Defense)**：識別「保護色」。是否在釋放張力後利用專業身分或玩笑掩飾真心。

每個維度回傳格式：\`{score: 0-10, description: "具體評語"}\`

## 任務 3：深度分析 (Deep Insight)

1. **relationshipStatus**: 4-6 字定義，需包含狀態比喻（如：「溫水煮青蛙」、「只差一個契機」、「文藝式互撩」、「純種工具人」），如果分數不高，就很清楚的表達，不需要太nice。
2. **summary**: 200-400 字。解構「心理博弈」。點破那層「專業掩護」下的真實情感。
3. **toneInsight**: 氛圍洞察（如：生活感極強的親暱、充滿試探的拉扯）。
4. **wittyConclusion**: 犀利且一針見血的金句（Mic-drop style）。
5. **totalScore**: 總分，0-10分(整數)，總分。根據分數梯度評分，對話中出現【唯一性宣告】、【智力博弈】或【共謀感】，總分應直接從 7.5 分起跳，不論其他維度（如生活滲透度）是否偏低。

## 任務 4 逐句心理拆解 (Sentence Analysis & Wrap-up)
逐句心理拆解，回傳的順序必續按照當初對話的順序先後。

1. 選出 3-8 句關鍵對話，每句提供：
   - \`originalText\`: 原始對話內容。如果是連續的對話，情境相關可以合併成一句話。（如：如果把"我""愛""你"分成三個對話送出，分析時應該合併成一句話"我愛你"。）
   - \`speaker\`: 發話者（"me" 或 "partner"）
   - \`hiddenMeaning\`: 背後含意（潛台詞），分析戰術（如：生活滲透、直球進攻、假性拒絕、情感索求）。(約30-100字, 越是轉折的關鍵句，分析字數越多)
   - \`flirtScore\`: 1-10 星評分
   - \`scoreReason\`: 解釋為何這句生活化對話能拉高或降低曖昧度。(約30-100字, 越是轉折的關鍵句，分析字數越多)

2. **advancedSummary**: 針對這幾句對話的互動細節，給出一段溫暖或犀利的總結（約 50-200 字，曖昧程度越高，字數越多），用來放在進階分析頁面的底部

## 輸出格式要求

**重要：你必須嚴格遵守以下 JSON Schema，使用 ${responseLanguage} 回覆：**

\`\`\`json
{
  "partnerName": "對方名稱（由你推測，如果無法推測則顯示「對方」）",
  "radar": {
      "tension": {"score": 0.0, "description": "評語"},
      "disclosure": {"score": 0.0, "description": "評語"},
      "momentum": {"score": 0.0, "description": "評語"},  
      "exclusivity": {"score": 0.0, "description": "評語"},
      "baiting": {"score": 0.0, "description": "評語"},
      "defense": {"score": 0.0, "description": "評語"}
    },
  "totalScore": 0-10,
  "relationshipStatus": "4-6字狀態短語",
  "summary": "深度分析",
  "toneInsight": "氛圍洞察內容",
  "wittyConclusion": "犀利金句（可選）",
  "sentences": [
    {
      "originalText": "原始對話內容。如果是連續的對話，情境相關可以合併成一句話",
      "speaker": "me|partner",
      "hiddenMeaning": "背後含意",
      "flirtScore": 1-10,
      "scoreReason": "分數說明"
    }
  ],
  "advancedSummary": "進階頁面底部的總結"
}
\`\`\`

**注意事項：**
- 如果圖片不是對話截圖，只回傳 \`{"error": "invalid_image_content"}\`
- 所有文字內容使用 ${responseLanguage}
- 確保 JSON 格式正確，可以被解析
- totalScore 是對整體曖昧程度的評分（0-10）
- sentences 陣列必須包含 3-5 個元素`;

      // 記錄準備呼叫 OpenAI API
      functions.logger.info("準備呼叫 OpenAI Vision API", {
        model: "gpt-4o-mini",
        imageBase64Length: imageBase64.length,
        language: language,
      });

      const startTime = Date.now();

      // 呼叫 OpenAI Vision API
      let completion;
      try {
        completion = await openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content: systemPrompt,
            },
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text: "請分析這張對話截圖，並回傳符合 JSON Schema 的結果。",
                },
                {
                  type: "image_url",
                  image_url: {
                    url: `data:image/jpeg;base64,${imageBase64}`,
                  },
                },
              ],
            },
          ],
          response_format: { type: "json_object" },
          temperature: 0.7,
          max_tokens: 4000,
        });

        const endTime = Date.now();
        const duration = endTime - startTime;

        functions.logger.info("OpenAI API 調用成功", {
          duration: `${duration}ms`,
          hasResponse: !!completion.choices[0]?.message?.content,
          usage: completion.usage ? {
            promptTokens: completion.usage.prompt_tokens,
            completionTokens: completion.usage.completion_tokens,
            totalTokens: completion.usage.total_tokens,
          } : null,
        });
      } catch (openaiError: any) {
        const endTime = Date.now();
        const duration = endTime - startTime;

        functions.logger.error("OpenAI API 調用失敗", {
          error: openaiError.message,
          status: openaiError.status,
          code: openaiError.code,
          duration: `${duration}ms`,
        });

        throw new functions.https.HttpsError(
          "internal",
          `OpenAI API 調用失敗: ${openaiError.message}`
        );
      }

      const responseContent = completion.choices[0]?.message?.content;

      if (!responseContent) {
        throw new functions.https.HttpsError(
          "internal",
          "OpenAI API 未回傳內容"
        );
      }

      // 解析 JSON 回應
      let analysisResult;
      try {
        functions.logger.info("開始解析 OpenAI 回應", {
          responseLength: responseContent.length,
          responsePreview: responseContent.substring(0, 200),
        });

        analysisResult = JSON.parse(responseContent);

        functions.logger.info("JSON 解析成功", {
          hasRadar: !!analysisResult.radar,
          hasTotalScore: typeof analysisResult.totalScore !== "undefined",
          sentencesCount: analysisResult.sentences?.length || 0,
        });

        // 記錄完整的 OpenAI 分析結果原始資料
        functions.logger.info("完整分析結果（OpenAI 原始回應）", {
          fullAnalysisResult: analysisResult,
          rawResponseLength: responseContent.length,
        });
      } catch (parseError) {
        functions.logger.error("JSON 解析錯誤", {
          error: parseError,
          responsePreview: responseContent.substring(0, 500),
        });
        throw new functions.https.HttpsError(
          "internal",
          "無法解析 OpenAI 回應"
        );
      }

      // 檢查是否為無效圖片內容
      if (analysisResult.error === "invalid_image_content") {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "invalid_image_content",
          { message: "這似乎不是對話紀錄喔" }
        );
      }

      // 驗證必要欄位
      const requiredFields = [
        "radar",
        "totalScore",
        "relationshipStatus",
        "summary",
        "toneInsight",
        "sentences",
        "advancedSummary",
      ];

      for (const field of requiredFields) {
        if (!(field in analysisResult)) {
          functions.logger.warn(`缺少欄位: ${field}`, analysisResult);
        }
      }

      // 確保 sentences 是陣列且長度正確
      if (!Array.isArray(analysisResult.sentences)) {
        analysisResult.sentences = [];
      }

      // 確保 radar 物件存在且每個 metric 都有 score 和 description
      if (!analysisResult.radar || typeof analysisResult.radar !== "object") {
        analysisResult.radar = {};
      }
      const metrics = ["tension", "disclosure", "momentum", "exclusivity", "baiting", "defense"];
      for (const metric of metrics) {
        if (!analysisResult.radar[metric] || typeof analysisResult.radar[metric] !== "object") {
          analysisResult.radar[metric] = { score: 0, description: "無法分析" };
        }
        if (typeof analysisResult.radar[metric].score !== "number") {
          analysisResult.radar[metric].score = 0;
        }
        if (typeof analysisResult.radar[metric].description !== "string") {
          analysisResult.radar[metric].description = "無法分析";
        }
      }

      // 回傳分析結果
      functions.logger.info("分析完成，準備回傳結果", {
        totalScore: analysisResult.totalScore,
        relationshipStatus: analysisResult.relationshipStatus,
      });

      return {
        success: true,
        data: analysisResult,
      };
    } catch (error: any) {
      functions.logger.error("分析錯誤", {
        error: error.message,
        code: error.code,
        stack: error.stack,
      });

      // 如果是 HttpsError，直接拋出
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // 其他錯誤統一處理
      throw new functions.https.HttpsError(
        "internal",
        "分析過程中發生錯誤",
        error.message
      );
    }
  }
);

// 範例 Cloud Function（保留供參考）
export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.json({message: "Hello from Firebase!"});
});

