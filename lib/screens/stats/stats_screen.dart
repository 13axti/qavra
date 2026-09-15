import 'package:flutter/material.dart';
import '../../core/progress_service.dart';
import '../../core/theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = ProgressService.streak;
    final total = ProgressService.totalWordsLearned;
    final today = ProgressService.todayWordCount;
    final level = ProgressService.userLevel;
    final dueCount = ProgressService.getDueReviews().length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistika')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _BigStat(
              icon: Icons.local_fire_department,
              value: '$streak',
              label: 'Gün ardıcıl',
              color: AppColors.streak,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SmallStat(
                    icon: Icons.check_circle_outline,
                    value: '$total',
                    label: 'Cəmi söz',
                    color: AppColors.correct,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallStat(
                    icon: Icons.today,
                    value: '$today',
                    label: 'Bu gün',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SmallStat(
                    icon: Icons.refresh,
                    value: '$dueCount',
                    label: 'Təkrar gözlər',
                    color: AppColors.wrong,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallStat(
                    icon: Icons.school,
                    value: level,
                    label: 'Səviyyə',
                    color: AppColors.subtext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proqres', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _ProgressRow(label: 'A1 (500 söz)', current: total, total: 500),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _BigStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SmallStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int current;
  final int total;

  const _ProgressRow({required this.label, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (current / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text('$current / $total', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
