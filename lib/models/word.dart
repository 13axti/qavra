class Word {
  final String id;
  final String word;
  final String translation;
  final String example;
  final String exampleAz;
  final String level;
  final String category;

  const Word({
    required this.id,
    required this.word,
    required this.translation,
    required this.example,
    required this.exampleAz,
    required this.level,
    required this.category,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json['id'] as String,
        word: json['word'] as String,
        translation: json['translation'] as String,
        example: json['example'] as String,
        exampleAz: json['example_az'] as String,
        level: json['level'] as String,
        category: json['category'] as String,
      );
}
