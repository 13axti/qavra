import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FillBlankWidget extends StatefulWidget {
  final String sentence;
  final List<String> options;
  final int correctIndex;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const FillBlankWidget({
    super.key,
    required this.sentence,
    required this.options,
    required this.correctIndex,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  int? _selected;

  void _pick(int i) {
    if (_selected != null) return;
    setState(() => _selected = i);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (i == widget.correctIndex) {
        widget.onCorrect();
      } else {
        widget.onWrong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Boşluğu doldur', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.sentence,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(widget.options.length, (i) {
          Color bg = AppColors.surfaceVariant;
          Color border = Colors.transparent;
          if (_selected != null) {
            if (i == widget.correctIndex) {
              bg = AppColors.correct.withValues(alpha: 0.2);
              border = AppColors.correct;
            } else if (i == _selected) {
              bg = AppColors.wrong.withValues(alpha: 0.2);
              border = AppColors.wrong;
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _pick(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 1.5),
                ),
                child: Text(widget.options[i], style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
          );
        }),
      ],
    );
  }
}
