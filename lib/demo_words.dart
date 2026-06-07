class DemoWord {
  const DemoWord({
    required this.source,
    required this.target,
    required this.wrongAnswers,
  });

  final String source;
  final String target;
  final List<String> wrongAnswers;
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
