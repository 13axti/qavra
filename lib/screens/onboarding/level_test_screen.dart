import 'package:flutter/material.dart';
import '../../core/progress_service.dart';
import '../../core/theme.dart';
import '../home/home_screen.dart';

class _Question {
  final String sentence;
  final List<String> options;
  final int correctIndex;
  final String level;

  const _Question({
    required this.sentence,
    required this.options,
    required this.correctIndex,
    required this.level,
  });
}

const _questions = <_Question>[
  // A1
  _Question(
    sentence: '"Salam" ingilis dilində necə deyilir?',
    options: ['Goodbye', 'Hello', 'Thank you', 'Sorry'],
    correctIndex: 1,
    level: 'A1',
  ),
  _Question(
    sentence: 'Boşluğu doldur: "I ___ a student."',
    options: ['are', 'is', 'am', 'be'],
    correctIndex: 2,
    level: 'A1',
  ),
  _Question(
    sentence: '"Kitab" ingilis dilində:',
    options: ['Chair', 'Table', 'Book', 'Pen'],
    correctIndex: 2,
    level: 'A1',
  ),
  // A2
  _Question(
    sentence: 'Boşluğu doldur: "She ___ to school every day."',
    options: ['go', 'goes', 'going', 'gone'],
    correctIndex: 1,
    level: 'A2',
  ),
  _Question(
    sentence: '"I have lived here ___ 5 years." — Düzgün söz:',
    options: ['since', 'for', 'ago', 'from'],
    correctIndex: 1,
    level: 'A2',
  ),
  _Question(
    sentence: 'Hansı cümlə düzgündür?',
    options: [
      'He don\'t like coffee.',
      'He doesn\'t likes coffee.',
      'He doesn\'t like coffee.',
      'He not like coffee.',
    ],
    correctIndex: 2,
    level: 'A2',
  ),
  // B1
  _Question(
    sentence: 'Boşluğu doldur: "By the time she arrived, he ___ already left."',
    options: ['has', 'had', 'have', 'was'],
    correctIndex: 1,
    level: 'B1',
  ),
  _Question(
    sentence: '"Despite" sözünün mənası:',
    options: ['Çünki', 'Baxmayaraq ki', 'Əgər', 'Həmçinin'],
    correctIndex: 1,
    level: 'B1',
  ),
];

class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  int _current = 0;
  int _correctA2 = 0;
  int _correctB1 = 0;
  int? _selected;
  bool _answered = false;

  void _answer(int index) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
    });

    final q = _questions[_current];
    if (index == q.correctIndex) {
      if (q.level == 'A2') _correctA2++;
      if (q.level == 'B1') _correctB1++;
    }

    Future.delayed(const Duration(milliseconds: 900), _next);
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    String level;
    if (_correctB1 >= 1) {
      level = 'B1';
    } else if (_correctA2 >= 2) {
      level = 'A2';
    } else {
      level = 'A1';
    }
    ProgressService.completeOnboarding(level);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Səviyyə testi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
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
              Text(
                '${_current + 1} / ${_questions.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  q.sentence,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              ...List.generate(q.options.length, (i) {
                Color bg = AppColors.surfaceVariant;
                if (_answered) {
                  if (i == q.correctIndex) bg = AppColors.correct.withValues(alpha: 0.3);
                  if (i == _selected && i != q.correctIndex) bg = AppColors.wrong.withValues(alpha: 0.3);
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _answer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _answered && i == q.correctIndex
                              ? AppColors.correct
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        q.options[i],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
