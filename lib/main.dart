import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/presentation/editor/screens/editor_screen.dart';
import 'src/core/constants/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TournaXBuilderApp(),
    ),
  );
}

class TournaXBuilderApp extends StatelessWidget {
  const TournaXBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TournaX Widget Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.accentPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentPrimary,
          secondary: AppColors.accentSecondary,
          surface: AppColors.panelBackground,
        ),
        dividerColor: AppColors.borderDark,
      ),
      home: const EditorScreen(),
    );
  }
}
