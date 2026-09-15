import 'package:flutter/material.dart';
import '../../core/progress_service.dart';
import '../../core/theme.dart';
import '../../models/word.dart';
import '../../widgets/exercise_widgets/word_order_widget.dart';
import '../../widgets/exercise_widgets/fill_blank_widget.dart';
import '../../widgets/exercise_widgets/type_answer_widget.dart';
import '../home/home_screen.dart';

enum _ExType { wordOrder, fillBlank, typeAnswer }

class _Exercise {
  final _ExType type;
  final Word word;
  _Exercise(this.type, this.word);
}

class ExerciseScreen extends StatefulWidget {
  final List<Word> words;
  const ExerciseScreen({super.key, required this.words});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late List<_Exercise> _exercises;
  int _index = 0;
  int _correct = 0;
  int _wrong = 0;

  @override
  void initState() {
    super.initState();
    _exercises = _buildExercises(widget.words);
  }

  List<_Exercise> _buildExercises(List<Word> words) {
    final list = <_Exercise>[];
    final types = [_ExType.wordOrder, _ExType.fillBlank, _ExType.typeAnswer];
    for (int i = 0; i < words.length; i++) {
      list.add(_Exercise(types[i % types.length], words[i]));
    }
    list.shuffle();
    return list;
  }

  void _onCorrect() {
    ProgressService.recordReview(_exercises[_index].word.id, 5);
    _correct++;
    _advance();
  }

  void _onWrong() {
    ProgressService.recordReview(_exercises[_index].word.id, 0);
    _wrong++;
    _advance();
  }

  void _advance() {
    if (_index < _exercises.length - 1) {
      setState(() => _index++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Dərs tamamlandı!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.streak, size: 48),
            const SizedBox(height: 12),
            Text(
              '$_correct / ${_exercises.length} düz cavab',
              style: const TextStyle(fontSize: 18, color: AppColors.text),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (r) => false,
              );
            },
            child: const Text('Ana səhifəyə qayıt', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildExercise(_Exercise ex) {
    final word = ex.word;
    switch (ex.type) {
      case _ExType.wordOrder:
        return WordOrderWidget(
          key: ValueKey('wo_$_index'),
          sentence: word.example.replaceAll(RegExp(r'[.!?]$'), ''),
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        );
      case _ExType.fillBlank:
        final blank = word.example.replaceFirst(word.word, '___');
        final others = widget.words
            .where((w) => w.id != word.id)
            .take(3)
            .map((w) => w.word)
            .toList();
        final options = [word.word, ...others]..shuffle();
        final correctIdx = options.indexOf(word.word);
        return FillBlankWidget(
          key: ValueKey('fb_$_index'),
          sentence: blank,
          options: options,
          correctIndex: correctIdx,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        );
      case _ExType.typeAnswer:
        return TypeAnswerWidget(
          key: ValueKey('ta_$_index'),
          question: '"${word.translation}" ingilis dilində necə deyilir?',
          correctAnswer: word.word,
          hint: 'Nümunə: ${word.example}',
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Məşq'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (r) => false,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_index + 1} / ${_exercises.length}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Row(
                    children: [
                      const Icon(Icons.check, color: AppColors.correct, size: 16),
                      const SizedBox(width: 4),
                      Text('$_correct', style: const TextStyle(color: AppColors.correct)),
                      const SizedBox(width: 12),
                      const Icon(Icons.close, color: AppColors.wrong, size: 16),
                      const SizedBox(width: 4),
                      Text('$_wrong', style: const TextStyle(color: AppColors.wrong)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildExercise(_exercises[_index]),
            ],
          ),
        ),
      ),
    );
  }
}
