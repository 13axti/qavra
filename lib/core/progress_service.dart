import 'package:hive_flutter/hive_flutter.dart';
import 'hive_boxes.dart';
import 'srs_engine.dart';

class ProgressService {
  static Box get _box => Hive.box(HiveBoxes.progress);

  static bool get onboardingDone => _box.get(HiveKeys.onboardingDone, defaultValue: false);
  static String get userLevel => _box.get(HiveKeys.userLevel, defaultValue: 'A1');
  static int get streak => _box.get(HiveKeys.streak, defaultValue: 0);
  static int get totalWordsLearned => _box.get(HiveKeys.totalWordsLearned, defaultValue: 0);

  static void completeOnboarding(String level) {
    _box.put(HiveKeys.onboardingDone, true);
    _box.put(HiveKeys.userLevel, level);
  }

  static Map<String, WordProgress> get allWordProgress {
    final raw = _box.get(HiveKeys.wordProgress, defaultValue: <String, dynamic>{});
    return {
      for (final e in (raw as Map).entries)
        e.key as String: WordProgress.fromMap(e.value as Map),
    };
  }

  static Set<String> get learnedWordIds => allWordProgress.keys.toSet();

  static List<WordProgress> getDueReviews() {
    return allWordProgress.values.where((wp) => wp.isDueForReview).toList();
  }

  static void saveWordReview(WordProgress wp) {
    final raw = Map<String, dynamic>.from(
      _box.get(HiveKeys.wordProgress, defaultValue: <String, dynamic>{}),
    );
    raw[wp.wordId] = wp.toMap();
    _box.put(HiveKeys.wordProgress, raw);
  }

  static void markWordLearned(String wordId) {
    final wp = WordProgress(wordId: wordId);
    saveWordReview(wp);
    _box.put(HiveKeys.totalWordsLearned, totalWordsLearned + 1);
    _updateTodayCount();
  }

  static void recordReview(String wordId, int quality) {
    final all = allWordProgress;
    final wp = all[wordId] ?? WordProgress(wordId: wordId);
    saveWordReview(reviewWord(wp, quality));
  }

  static int get todayWordCount {
    final today = _todayStr();
    if (_box.get(HiveKeys.todayDate) != today) return 0;
    return _box.get(HiveKeys.todayWordCount, defaultValue: 0);
  }

  static void _updateTodayCount() {
    final today = _todayStr();
    if (_box.get(HiveKeys.todayDate) != today) {
      _box.put(HiveKeys.todayDate, today);
      _box.put(HiveKeys.todayWordCount, 1);
      _updateStreak();
    } else {
      _box.put(HiveKeys.todayWordCount, todayWordCount + 1);
    }
  }

  static void _updateStreak() {
    final lastDate = _box.get(HiveKeys.lastStudyDate, defaultValue: '');
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    if (lastDate == yesterdayStr) {
      _box.put(HiveKeys.streak, streak + 1);
    } else if (lastDate != _todayStr()) {
      _box.put(HiveKeys.streak, 1);
    }
    _box.put(HiveKeys.lastStudyDate, _todayStr());
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
