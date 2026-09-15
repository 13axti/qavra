class WordProgress {
  final String wordId;
  int interval;
  double easeFactor;
  int repetitions;
  DateTime nextReview;
  DateTime learnedAt;

  WordProgress({
    required this.wordId,
    this.interval = 1,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    DateTime? nextReview,
    DateTime? learnedAt,
  })  : nextReview = nextReview ?? DateTime.now(),
        learnedAt = learnedAt ?? DateTime.now();

  bool get isDueForReview => DateTime.now().isAfter(nextReview);

  Map<String, dynamic> toMap() => {
        'wordId': wordId,
        'interval': interval,
        'easeFactor': easeFactor,
        'repetitions': repetitions,
        'nextReview': nextReview.millisecondsSinceEpoch,
        'learnedAt': learnedAt.millisecondsSinceEpoch,
      };

  factory WordProgress.fromMap(Map map) => WordProgress(
        wordId: map['wordId'],
        interval: map['interval'] ?? 1,
        easeFactor: (map['easeFactor'] ?? 2.5).toDouble(),
        repetitions: map['repetitions'] ?? 0,
        nextReview: DateTime.fromMillisecondsSinceEpoch(map['nextReview'] ?? 0),
        learnedAt: DateTime.fromMillisecondsSinceEpoch(map['learnedAt'] ?? 0),
      );
}

// SM-2 alqoritmi: quality 0=səhv, 3=yardımla düz, 5=asanlıqla düz
WordProgress reviewWord(WordProgress wp, int quality) {
  if (quality < 3) {
    wp.repetitions = 0;
    wp.interval = 1;
  } else {
    if (wp.repetitions == 0) {
      wp.interval = 1;
    } else if (wp.repetitions == 1) {
      wp.interval = 6;
    } else {
      wp.interval = (wp.interval * wp.easeFactor).round();
    }
    wp.repetitions++;
  }

  wp.easeFactor += 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
  if (wp.easeFactor < 1.3) wp.easeFactor = 1.3;

  wp.nextReview = DateTime.now().add(Duration(days: wp.interval));
  return wp;
}
