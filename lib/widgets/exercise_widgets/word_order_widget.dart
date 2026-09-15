import 'package:flutter/material.dart';
import '../../core/theme.dart';

class WordOrderWidget extends StatefulWidget {
  final String sentence;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const WordOrderWidget({
    super.key,
    required this.sentence,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<WordOrderWidget> createState() => _WordOrderWidgetState();
}

class _WordOrderWidgetState extends State<WordOrderWidget> {
  late List<String> _shuffled;
  final List<String> _selected = [];
  bool? _result;

  @override
  void initState() {
    super.initState();
    _shuffled = widget.sentence
        .replaceAll(RegExp(r'[.!?]'), '')
        .split(' ')
      ..shuffle();
  }

  void _tap(String word) {
    if (_result != null) return;
    setState(() {
      _selected.add(word);
      _shuffled.remove(word);
    });
  }

  void _remove(int i) {
    if (_result != null) return;
    setState(() {
      _shuffled.add(_selected[i]);
      _selected.removeAt(i);
    });
  }

  void _check() {
    final answer = _selected.join(' ');
    final correct = widget.sentence.replaceAll(RegExp(r'[.!?]'), '');
    final isCorrect = answer.toLowerCase() == correct.toLowerCase();
    setState(() => _result = isCorrect);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (isCorrect) {
        widget.onCorrect();
      } else {
        widget.onWrong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _result == null
        ? AppColors.surface
        : _result!
            ? AppColors.correct.withValues(alpha: 0.15)
            : AppColors.wrong.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cümləni düz sırala', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: resultColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _result == null
                  ? AppColors.subtext.withValues(alpha: 0.3)
                  : _result!
                      ? AppColors.correct
                      : AppColors.wrong,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_selected.length, (i) {
              return GestureDetector(
                onTap: () => _remove(i),
                child: Chip(
                  label: Text(_selected[i]),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(color: AppColors.text),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _shuffled.map((w) {
            return GestureDetector(
              onTap: () => _tap(w),
              child: Chip(
                label: Text(w),
                backgroundColor: AppColors.surfaceVariant,
                side: BorderSide.none,
                labelStyle: const TextStyle(color: AppColors.text),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        if (_selected.isNotEmpty && _result == null)
          ElevatedButton(
            onPressed: _check,
            child: const Text('Yoxla'),
          ),
        if (_result != null)
          Text(
            _result! ? 'Düzdür!' : 'Səhvdir. Düzgün: ${widget.sentence}',
            style: TextStyle(
              color: _result! ? AppColors.correct : AppColors.wrong,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
