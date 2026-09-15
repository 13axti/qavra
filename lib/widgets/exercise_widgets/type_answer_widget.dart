import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TypeAnswerWidget extends StatefulWidget {
  final String question;
  final String correctAnswer;
  final String hint;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const TypeAnswerWidget({
    super.key,
    required this.question,
    required this.correctAnswer,
    required this.hint,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<TypeAnswerWidget> createState() => _TypeAnswerWidgetState();
}

class _TypeAnswerWidgetState extends State<TypeAnswerWidget> {
  final _controller = TextEditingController();
  bool? _result;

  void _check() {
    final input = _controller.text.trim().toLowerCase();
    final correct = widget.correctAnswer.toLowerCase();
    final isCorrect = input == correct;
    setState(() => _result = isCorrect);
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (isCorrect) {
        widget.onCorrect();
      } else {
        widget.onWrong();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('İngilis dilində yaz', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.question,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(widget.hint, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          enabled: _result == null,
          autofocus: true,
          style: const TextStyle(color: AppColors.text, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Cavabını yaz...',
            hintStyle: const TextStyle(color: AppColors.subtext),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          onSubmitted: (_) => _check(),
        ),
        const SizedBox(height: 16),
        if (_result == null)
          ElevatedButton(
            onPressed: _controller.text.trim().isEmpty ? null : _check,
            child: const Text('Yoxla'),
          ),
        if (_result != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _result!
                  ? AppColors.correct.withValues(alpha: 0.15)
                  : AppColors.wrong.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _result! ? 'Əla! Düzdür.' : 'Düzgün cavab: ${widget.correctAnswer}',
              style: TextStyle(
                color: _result! ? AppColors.correct : AppColors.wrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
