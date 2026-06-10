class CatchWord {
  const CatchWord({
    required this.id,
    required this.source,
    required this.translation,
    required this.category,
    this.languageCode = 'id',
    this.confidence = 1,
    this.markerX = 0,
    this.markerY = 0,
    this.caughtAt,
    this.seenCount = 0,
    this.lastSeenAt,
  });

  final String id;
  final String source;
  final String translation;
  final String category;
  final String languageCode;
  final double confidence;
  final double markerX;
  final double markerY;
  final DateTime? caughtAt;
  final int seenCount;
  final DateTime? lastSeenAt;

  CatchWord caughtNow() {
    final now = DateTime.now();

    return CatchWord(
      id: id,
      source: source,
      translation: translation,
      category: category,
      languageCode: languageCode,
      confidence: confidence,
      markerX: markerX,
      markerY: markerY,
      caughtAt: caughtAt ?? now,
      seenCount: seenCount + 1,
      lastSeenAt: now,
    );
  }

  CatchWord seenAgain() {
    return CatchWord(
      id: id,
      source: source,
      translation: translation,
      category: category,
      languageCode: languageCode,
      confidence: confidence,
      markerX: markerX,
      markerY: markerY,
      caughtAt: caughtAt,
      seenCount: seenCount + 1,
      lastSeenAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'translation': translation,
      'category': category,
      'languageCode': languageCode,
      'confidence': confidence,
      'markerX': markerX,
      'markerY': markerY,
      'caughtAt': caughtAt?.toIso8601String(),
      'seenCount': seenCount,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
    };
  }

  factory CatchWord.fromMap(Map<String, dynamic> map) {
    return CatchWord(
      id: map['id'] as String,
      source: map['source'] as String,
      translation: map['translation'] as String,
      category: map['category'] as String,
      languageCode: map['languageCode'] as String? ?? 'id',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 1,
      markerX: (map['markerX'] as num?)?.toDouble() ?? 0,
      markerY: (map['markerY'] as num?)?.toDouble() ?? 0,
      caughtAt: map['caughtAt'] == null
          ? null
          : DateTime.parse(map['caughtAt'] as String),
      seenCount: map['seenCount'] as int? ?? 1,
      lastSeenAt: map['lastSeenAt'] == null
          ? null
          : DateTime.parse(map['lastSeenAt'] as String),
    );
  }
}
