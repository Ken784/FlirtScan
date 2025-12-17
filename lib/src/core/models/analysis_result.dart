/// 雷達圖維度
class RadarMetric {
  final double score; // 0-10 分
  final String description; // 該維度的具體評語

  RadarMetric({
    required this.score,
    required this.description,
  });

  factory RadarMetric.fromJson(Map<String, dynamic> json) {
    return RadarMetric(
      score: (json['score'] as num).toDouble(),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'description': description,
    };
  }
}

/// 發話者
enum Speaker {
  me,
  partner,
  unknown,
}

/// 逐句分析
class SentenceAnalysis {
  final String originalText; // 原始對話內容
  final Speaker speaker; // 發話者
  final String hiddenMeaning; // 背後含意（潛台詞）
  final int flirtScore; // 1-10 星
  final String scoreReason; // 分數說明

  SentenceAnalysis({
    required this.originalText,
    required this.speaker,
    required this.hiddenMeaning,
    required this.flirtScore,
    required this.scoreReason,
  });

  factory SentenceAnalysis.fromJson(Map<String, dynamic> json) {
    return SentenceAnalysis(
      originalText: json['originalText'] as String,
      speaker: _speakerFromString(json['speaker'] as String),
      hiddenMeaning: json['hiddenMeaning'] as String,
      flirtScore: json['flirtScore'] as int,
      scoreReason: json['scoreReason'] as String,
    );
  }

  static Speaker _speakerFromString(String value) {
    switch (value.toLowerCase()) {
      case 'me':
        return Speaker.me;
      case 'partner':
        return Speaker.partner;
      default:
        return Speaker.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'speaker': speaker.name,
      'hiddenMeaning': hiddenMeaning,
      'flirtScore': flirtScore,
      'scoreReason': scoreReason,
    };
  }
}

/// 完整分析結果
class AnalysisResult {
  final String id;
  final DateTime createdAt; // 建立時間
  final String partnerName; // 對方名稱

  // 雷達圖五維度
  final RadarMetric emotional;
  final RadarMetric intimacy;
  final RadarMetric playfulness;
  final RadarMetric responsive;
  final RadarMetric balance;

  final double totalScore; // 總分
  final String relationshipStatus; // 關係狀態短語
  final String summary; // 總結
  final String toneInsight; // 語氣洞察
  final String wittyConclusion; // 金句（可選）

  // 進階分析相關
  final List<SentenceAnalysis> sentences; // 逐句分析列表
  final String advancedSummary; // 進階頁面底部的總結

  // 狀態標記
  final bool isAdvancedUnlocked; // 是否已解鎖進階分析

  AnalysisResult({
    required this.id,
    required this.createdAt,
    required this.partnerName,
    required this.emotional,
    required this.intimacy,
    required this.playfulness,
    required this.responsive,
    required this.balance,
    required this.totalScore,
    required this.relationshipStatus,
    required this.summary,
    required this.toneInsight,
    required this.wittyConclusion,
    required this.sentences,
    required this.advancedSummary,
    this.isAdvancedUnlocked = false,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json, {String? id}) {
    return AnalysisResult(
      // 優先使用傳入的 id，否則從 JSON 中讀取，最後才生成新的
      id: id ??
          (json['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      partnerName: json['partnerName'] as String? ?? '對方',
      // 安全轉換嵌套的 Map
      emotional: RadarMetric.fromJson(
          Map<String, dynamic>.from(json['emotional'] as Map)),
      intimacy: RadarMetric.fromJson(
          Map<String, dynamic>.from(json['intimacy'] as Map)),
      playfulness: RadarMetric.fromJson(
          Map<String, dynamic>.from(json['playfulness'] as Map)),
      responsive: RadarMetric.fromJson(
          Map<String, dynamic>.from(json['responsive'] as Map)),
      balance: RadarMetric.fromJson(
          Map<String, dynamic>.from(json['balance'] as Map)),
      totalScore: (json['totalScore'] as num).toDouble(),
      relationshipStatus: json['relationshipStatus'] as String,
      summary: json['summary'] as String,
      toneInsight: json['toneInsight'] as String,
      wittyConclusion: json['wittyConclusion'] as String? ?? '',
      // 安全轉換 List 中的 Map
      sentences: (json['sentences'] as List<dynamic>?)
              ?.map((e) => SentenceAnalysis.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      advancedSummary: json['advancedSummary'] as String,
      isAdvancedUnlocked: json['isAdvancedUnlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'partnerName': partnerName,
      'emotional': emotional.toJson(),
      'intimacy': intimacy.toJson(),
      'playfulness': playfulness.toJson(),
      'responsive': responsive.toJson(),
      'balance': balance.toJson(),
      'totalScore': totalScore,
      'relationshipStatus': relationshipStatus,
      'summary': summary,
      'toneInsight': toneInsight,
      'wittyConclusion': wittyConclusion,
      'sentences': sentences.map((e) => e.toJson()).toList(),
      'advancedSummary': advancedSummary,
      'isAdvancedUnlocked': isAdvancedUnlocked,
    };
  }

  /// 複製並更新部分欄位
  AnalysisResult copyWith({
    String? id,
    DateTime? createdAt,
    String? partnerName,
    RadarMetric? emotional,
    RadarMetric? intimacy,
    RadarMetric? playfulness,
    RadarMetric? responsive,
    RadarMetric? balance,
    double? totalScore,
    String? relationshipStatus,
    String? summary,
    String? toneInsight,
    String? wittyConclusion,
    List<SentenceAnalysis>? sentences,
    String? advancedSummary,
    bool? isAdvancedUnlocked,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      partnerName: partnerName ?? this.partnerName,
      emotional: emotional ?? this.emotional,
      intimacy: intimacy ?? this.intimacy,
      playfulness: playfulness ?? this.playfulness,
      responsive: responsive ?? this.responsive,
      balance: balance ?? this.balance,
      totalScore: totalScore ?? this.totalScore,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      summary: summary ?? this.summary,
      toneInsight: toneInsight ?? this.toneInsight,
      wittyConclusion: wittyConclusion ?? this.wittyConclusion,
      sentences: sentences ?? this.sentences,
      advancedSummary: advancedSummary ?? this.advancedSummary,
      isAdvancedUnlocked: isAdvancedUnlocked ?? this.isAdvancedUnlocked,
    );
  }
}
