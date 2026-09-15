import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/progress_service.dart';
import '../../core/theme.dart';
import '../../data/word_repository.dart';
import '../../models/word.dart';
import '../home/home_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FlutterTts _tts = FlutterTts();
  List<Word> _words = [];
  int _index = 0;
  bool _loading = true;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
    _load();
  }

  Future<void> _load() async {
    final due = ProgressService.getDueReviews();
    final ids = due.map((w) => w.wordId).toList();
    final words = await WordRepository.getWordsById(ids);
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  void _answer(int quality) {
    ProgressService.recordReview(_words[_index].id, quality);
    if (_index < _words.length - 1) {
      setState(() {
        _index++;
        _revealed = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Təkrar')),
        body: const Center(child: Text('Təkrar ediləcək söz yoxdur.')),
      );
    }

    final word = _words[_index];
    final progress = (_index + 1) / _words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Təkrar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
              Text('${_index + 1} / ${_words.length}', style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(color: AppColors.text, fontSize: 40, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 28, color: AppColors.primary),
                      onPressed: () => _tts.speak(word.word),
                    ),
                    if (_revealed) ...[
                      const Divider(color: AppColors.surfaceVariant, height: 32),
                      Text(
                        word.translation,
                        style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(word.example, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (!_revealed)
                ElevatedButton(
                  onPressed: () => setState(() => _revealed = true),
                  child: const Text('Mənasını göstər'),
                )
              else
                Column(
                  children: [
                    Text('Nə qədər rahat yadda saxladın?', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _AnswerButton(
                            label: 'Çətin',
                            color: AppColors.wrong,
                            onTap: () => _answer(0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AnswerButton(
                            label: 'Normal',
                            color: AppColors.streak,
                            onTap: () => _answer(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AnswerButton(
                            label: 'Asan',
                            color: AppColors.correct,
                            onTap: () => _answer(5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
