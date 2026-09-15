import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word.dart';

class WordRepository {
  static List<Word>? _cache;

  static Future<List<Word>> loadAll() async {
    if (_cache != null) return _cache!;
    final json = await rootBundle.loadString('assets/words/a1_words.json');
    final list = jsonDecode(json) as List;
    _cache = list.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  static Future<List<Word>> getNextBatch({
    required Set<String> learnedIds,
    int count = 10,
  }) async {
    final all = await loadAll();
    return all.where((w) => !learnedIds.contains(w.id)).take(count).toList();
  }

  static Future<List<Word>> getWordsById(List<String> ids) async {
    final all = await loadAll();
    final map = {for (final w in all) w.id: w};
    return ids.map((id) => map[id]).whereType<Word>().toList();
  }
}
