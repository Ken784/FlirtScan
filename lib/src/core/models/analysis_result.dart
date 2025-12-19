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

/// 雷達圖五維度
class Radar {
  final RadarMetric tension; // 撩撥張力
  final RadarMetric disclosure; // 自我揭露
  final RadarMetric energy; // 生活滲透度
  final RadarMetric exclusivity; // 專屬特權
  final RadarMetric connection; // 連結慾望

  Radar({
    required this.tension,
    required this.disclosure,
    required this.energy,
    required this.exclusivity,
    required this.connection,
  });

  factory Radar.fromJson(Map<String, dynamic> json) {
    final radarJson = json['radar'] as Map<String, dynamic>? ?? json;
    return Radar(
      tension: RadarMetric.fromJson(
          Map<String, dynamic>.from(radarJson['tension'] as Map)),
      disclosure: RadarMetric.fromJson(
          Map<String, dynamic>.from(radarJson['disclosure'] as Map)),
      energy: RadarMetric.fromJson(
          Map<String, dynamic>.from(radarJson['energy'] as Map)),
      exclusivity: RadarMetric.fromJson(
          Map<String, dynamic>.from(radarJson['exclusivity'] as Map)),
      connection: RadarMetric.fromJson(
          Map<String, dynamic>.from(radarJson['connection'] as Map)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tension': tension.toJson(),
      'disclosure': disclosure.toJson(),
      'energy': energy.toJson(),
      'exclusivity': exclusivity.toJson(),
      'connection': connection.toJson(),
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
  final Radar radar;

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
    required this.radar,
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
      // 安全轉換 radar 物件
      radar: Radar.fromJson(json),
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
      'radar': radar.toJson(),
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
    Radar? radar,
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
      radar: radar ?? this.radar,
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
