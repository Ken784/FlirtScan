### 設計系統與元件清單（草案）

請直接在此文件上做增修或註記，我會依你調整後的版本開始實作。

## 設計代幣 Design Tokens
- **色彩 Color**
  - **primary**: #F02D2D（主色、填色按鈕/強調）
  - **text.black**: #000000（標題/主文）
  - **text.black80**: rgba(0,0,0,0.8)（次要文字）
  - **bg.gradientTop**: #FFEEFE（頁面漸層上）
  - **bg.gradientBottom**: #E8F2FF（頁面漸層下）
  - **bg.pageAlt**: #FFFAFB（淺粉背景）
  - **surface**: #FFFFFF（卡片/對話框底）
  - **secondary.yellow**: #FFFEC0（逐句分析：對方卡片底）
  - **secondary.blue**: #D9F4FF（逐句分析：我方卡片底）
  - **overlay**: rgba(0,0,0,0.5)（遮罩）
  - **state.success**: #27CC1C（勾選/成功）

- **字體 Typography（SF Pro 為主，fallback: system-ui, -apple-system, Noto Sans CJK）**
  - Title1/Emphasized: 28/34, Bold
  - Title2/Emphasized: 22/28, Bold
  - Title3/Emphasized: 20/25, Semibold
  - Body/Regular: 17/22, Regular
  - Body/Emphasized: 17/22, Semibold
  - Callout/Regular: 16/21, Regular
  - Subheadline/Regular: 15/20, Regular
  - Footnote/Regular: 13/18, Regular
  - Caption1/Emphasized: 12/16, Medium

- **間距 Spacing（px）**
  - 4, 8, 10, 12, 16, 20, 24, 32, 36, 40, 52, 84

- **圓角 Radius（px）**
  - 4, 16, 24, 28（圖片框）, 30（膠囊按鈕）

- **陰影 Elevation**
  - card: 0 4 10 rgba(0,0,0,0.03)
  - navTop: 0 -4 10 rgba(0,0,0,0.04)
  - dialog: 0 4 8 rgba(0,0,0,0.08)

- **邊框 Border**
  - width: 1, 3, 8（圖片外框）
  - color.primary: #F02D2D

## 圖示庫 Icons（需建立命名與元件化）

## 版面與格線 Layout
- **頁面背景**: 上下漸層或 `bg.pageAlt`

## 元件庫 Components（網站）
- **排版/結構**
  - PageHeader（左側 icon + 標題：heart_outline 或 arrow-left）
  - TitleBar（工具列樣式）
  - BottomNavigation（Home, Inbox；含選中/未選中態）
  - SectionTitle / SubTitle

- **按鈕 Buttons**
  - Primary Filled（red, pill，可含左側 icon）
  - Secondary Outlined（red outline, pill）
  - Tertiary Ghost/Neutral（灰階，次要動作）
  - 狀態：hover / active / disabled
  - 尺寸：Default 52px 高；

- **輸入/上傳**
  - UploadCard（上傳對話截圖：空狀態、已選擇預覽、刪除按鈕）

- **卡片 Cards**
  - ListEntry（歷史紀錄：縮圖/標題(對方名稱)/分數/摘要）
  - ScoreSummary（曖昧指數卡：標題、副標、分數 9/10 顯示）
  - InsightCard（「語氣洞察」「總結」等）
  - QuoteAnalysisCard（逐句分析卡：對方黃底、我方藍底；含「背後含意」與星等+百分比）

- **資料視覺**
  - RadarChart（五維：情緒投入、語氣親密、玩笑/調情、回覆積極、互動平衡；含軸標與多層多邊形）

- **對話框與遮罩**
  - Modal/Dialog（標題、內文、單一主動作；搭配 overlay）

- **導覽/列表**
  - NavigationBar（頂部標題列）
  - BottomTabBar（兩項：Home / Inbox；含選中態）
  - HistoryList（多個 ListEntry）

- **分數/標記**
  - ScoreBadge（如 9/10，主色）
  - RatingStars（紅星 + 灰星，0–10 等級組合，附百分比）

- **狀態/回饋**
  - Toast/InlineError（可選；目前有錯誤 Dialog，可補輕量版）

- **裝飾/插圖**
  - ChatBubblesIllustration（首頁/空狀態）
  - 圖片框樣式（白色 8px 邊框 + 圓角 28）



