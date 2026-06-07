class DemoWord {
  const DemoWord({
    required this.source,
    required this.target,
    required this.wrongAnswers,
  });

  final String source;
  final String target;
  final List<String> wrongAnswers;

  factory DemoWord.fromMap(Map<String, dynamic> map) {
    return DemoWord(
      source: map['source'] as String,
      target: map['target'] as String,
      wrongAnswers: List<String>.from(map['wrongAnswers'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {'source': source, 'target': target, 'wrongAnswers': wrongAnswers};
  }
}

const demoWords = [
  DemoWord(
    source: 'makan',
    target: 'essen',
    wrongAnswers: ['trinken', 'Haus', 'Straße'],
  ),
  DemoWord(
    source: 'minum',
    target: 'trinken',
    wrongAnswers: ['essen', 'gehen', 'danke'],
  ),
  DemoWord(
    source: 'rumah',
    target: 'Haus',
    wrongAnswers: ['Straße', 'Wasser', 'Mensch'],
  ),
  DemoWord(
    source: 'jalan',
    target: 'Straße / gehen',
    wrongAnswers: ['essen', 'Haus', 'danke'],
  ),
  DemoWord(
    source: 'terima kasih',
    target: 'danke',
    wrongAnswers: ['bitte', 'morgen', 'gut'],
  ),
];
