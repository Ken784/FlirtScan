# OpenAI API Key 設定說明

## ⚠️ 重要：Firebase Functions Config 已棄用

`functions.config()` API 將在 2026 年 3 月後停止使用。請使用以下方式設定 API Key。

## 設定方式

### 方法 1: 使用環境變數（本地開發推薦）

在 `firebase/functions` 目錄下創建 `.env` 文件（此文件已在 .gitignore 中，不會被提交）：

```bash
cd firebase/functions
echo 'OPENAI_API_KEY=你的-OpenAI-API-Key' > .env
```

或在執行時設定：

```bash
export OPENAI_API_KEY="你的-OpenAI-API-Key"
npm run serve
```

### 方法 2: 使用 Firebase Secret Manager（生產環境推薦）

部署到 Firebase 時，使用 Secret Manager：

```bash
# 設定 Secret（會提示你輸入 API Key）
firebase functions:secrets:set OPENAI_API_KEY

# 部署時會自動注入到環境變數
firebase deploy --only functions
```

Secret Manager 會自動將 `OPENAI_API_KEY` 注入為環境變數，無需額外代碼修改。

## 取得 OpenAI API Key

1. 前往 [OpenAI Platform](https://platform.openai.com/)
2. 登入或註冊帳號
3. 前往 [API Keys](https://platform.openai.com/api-keys)
4. 點擊 "Create new secret key"
5. 複製生成的 API Key（只會顯示一次，請妥善保存）

## 注意事項

- ⚠️ **請勿將 API Key 提交到 Git 倉庫**
- ✅ 本地開發時使用 `.env` 文件（已加入 .gitignore）
- ✅ 生產環境使用 Firebase Secret Manager 來管理敏感資訊
- ✅ 定期輪換 API Key 以確保安全性
- ✅ 此設定方式符合 Firebase 新標準，2026 年後仍可使用

## 測試

設定完成後，可以透過 Firebase Emulator 或部署後測試：

```bash
# 本地測試
npm run serve

# 部署到 Firebase
npm run deploy
```

