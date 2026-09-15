import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/progress_service.dart';
import '../../core/theme.dart';
import '../../data/word_repository.dart';
import '../../models/word.dart';
import 'exercise_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final FlutterTts _tts = FlutterTts();
  List<Word> _words = [];
  int _index = 0;
  bool _loading = true;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _load();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
  }

  Future<void> _load() async {
    final learned = ProgressService.learnedWordIds;
    final words = await WordRepository.getNextBatch(learnedIds: learned, count: 10);
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  void _speak() => _tts.speak(_words[_index].word);

  void _knew() {
    ProgressService.markWordLearned(_words[_index].id);
    _advance();
  }

  void _didntKnow() {
    ProgressService.markWordLearned(_words[_index].id);
    _advance();
  }

  void _advance() {
    if (_index < _words.length - 1) {
      setState(() {
        _index++;
        _flipped = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ExerciseScreen(words: _words)),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yeni söz')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.streak, size: 64),
              const SizedBox(height: 16),
              Text('Bütün sözləri öyrəndiniz!', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Tezliklə yeni sözlər əlavə ediləcək.', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    final word = _words[_index];
    final progress = (_index + 1) / _words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni söz'),
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
              Text(
                '${_index + 1} / ${_words.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _flipped = !_flipped),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _flipped
                      ? _buildBackCard(context, word)
                      : _buildFrontCard(context, word),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _didntKnow,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        foregroundColor: AppColors.wrong,
                        side: const BorderSide(color: AppColors.wrong),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Bilmədim'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _knew,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: AppColors.correct,
                      ),
                      child: const Text('Bildim'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Karta toxun — mənasını gör',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context, Word word) {
    return Container(
      key: const ValueKey('front'),
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
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          IconButton(
            onPressed: _speak,
            icon: const Icon(Icons.volume_up_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(word.example, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBackCard(BuildContext context, Word word) {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            word.word,
            style: const TextStyle(color: AppColors.subtext, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            word.translation,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(word.example, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(word.exampleAz, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
