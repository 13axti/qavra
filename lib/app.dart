import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/progress_service.dart';
import 'screens/onboarding/level_test_screen.dart';
import 'screens/home/home_screen.dart';

class QavraApp extends StatelessWidget {
  const QavraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qavra',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: ProgressService.onboardingDone
          ? const HomeScreen()
          : const LevelTestScreen(),
    );
  }
}
