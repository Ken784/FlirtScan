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

// 分析對話截圖的 HTTPS Callable Function
export const analyzeConversation = functions.https.onCall(
  async (data, context) => {
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
      const systemPrompt = `你是一位幽默且犀利的戀愛專家，專門分析對話截圖中的曖昧關係。

## 前置任務 (Guardrail)
首先以視覺檢查圖片。如果圖片內容完全不是對話截圖（例如風景、自拍、食物照、寵物照等），請直接回傳 JSON：
\`\`\`json
{"error": "invalid_image_content"}
\`\`\`
不要進行後續分析。

## 任務 1 (Transcribe & Diarize)
閱讀圖片中的對話內容，區分發話者：
- 通常「右側」為 Me（使用者本人）
- 「左側」為 Partner（對方）
- 如果無法明確區分，標記為 unknown

## 任務 2 (Radar Analysis)
針對 5 個維度進行評分（每個維度 0-10 分），並提供具體評語：

1. **情緒投入度 (emotional)**: 評估是否願意展示情緒（開心、生氣、擔心、心疼、撒嬌）
2. **語氣親密度 (intimacy)**: 評估語氣是否輕、軟、甜、像講悄悄話
3. **玩笑調情度 (playfulness)**: 評估玩鬧、互相挑釁、半真半假的暗示程度
4. **回覆積極度 (responsive)**: 評估是否想聊天、回覆長度、主動開話題
5. **互動平衡度 (balance)**: 評估是否雙向互動、能量量級是否相當

每個維度回傳格式：\`{score: 0-10, description: "具體評語"}\`

## 任務 3 (Key Insight)

1. **relationshipStatus**: 用 4-6 個字定義這段關係的狀態（例如：「準告白狀態」、「友達以上」、「冷戰邊緣」、「純屬路人」）
2. **summary**: 提供條列式的總結分析（Main Summary），使用 bullet points 格式
3. **toneInsight**: 分析語氣特徵，描述對話的整體語調和氛圍

## 任務 4 (Sentence Analysis & Wrap-up)

1. 選出 3-5 句關鍵對話，每句提供：
   - \`originalText\`: 原始對話內容
   - \`speaker\`: 發話者（"me" 或 "partner" 或 "unknown"）
   - \`hiddenMeaning\`: 背後含意（潛台詞）
   - \`flirtScore\`: 1-10 星評分
   - \`scoreReason\`: 分數說明

2. **advancedSummary**: 針對這幾句對話的互動細節，給出一段溫暖或犀利的總結（約 50-80 字），用來放在進階分析頁面的底部

## 輸出格式要求

**重要：你必須嚴格遵守以下 JSON Schema，使用 ${responseLanguage} 回覆：**

\`\`\`json
{
  "partnerName": "對方名稱（由你推測，如果無法推測則顯示「對方」）",
  "emotional": {"score": 0-10, "description": "評語"},
  "intimacy": {"score": 0-10, "description": "評語"},
  "playfulness": {"score": 0-10, "description": "評語"},
  "responsive": {"score": 0-10, "description": "評語"},
  "balance": {"score": 0-10, "description": "評語"},
  "totalScore": 0-10,
  "relationshipStatus": "4-6字狀態短語",
  "summary": "條列式總結（可包含換行和 bullet points）",
  "toneInsight": "語氣洞察",
  "wittyConclusion": "金句（可選）",
  "sentences": [
    {
      "originalText": "原始對話",
      "speaker": "me|partner|unknown",
      "hiddenMeaning": "背後含意",
      "flirtScore": 1-10,
      "scoreReason": "分數說明"
    }
  ],
  "advancedSummary": "進階頁面底部的總結（50-80字）"
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
          hasEmotional: !!analysisResult.emotional,
          hasIntimacy: !!analysisResult.intimacy,
          hasTotalScore: typeof analysisResult.totalScore !== "undefined",
          sentencesCount: analysisResult.sentences?.length || 0,
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
        "emotional",
        "intimacy",
        "playfulness",
        "responsive",
        "balance",
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

      // 確保每個 metric 都有 score 和 description
      const metrics = ["emotional", "intimacy", "playfulness", "responsive", "balance"];
      for (const metric of metrics) {
        if (!analysisResult[metric] || typeof analysisResult[metric] !== "object") {
          analysisResult[metric] = { score: 0, description: "無法分析" };
        }
        if (typeof analysisResult[metric].score !== "number") {
          analysisResult[metric].score = 0;
        }
        if (typeof analysisResult[metric].description !== "string") {
          analysisResult[metric].description = "無法分析";
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

