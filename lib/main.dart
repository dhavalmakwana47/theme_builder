import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/presentation/template_manager/screens/template_manager_screen.dart';
import 'src/core/constants/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final src1 = File(r'C:\Users\Lenovo\.gemini\antigravity-ide\brain\49266b3a-adc8-4904-80a0-e3c780aa2b2e\tropical_beach_1785350772647.png');
    final dest1 = File(r'C:\Dhaval\flutter\Tournamnet App\Projects\TournaX\public\template_assets\slot_list_background\tropical_beach.png');
    if (src1.existsSync()) {
      dest1.parent.createSync(recursive: true);
      src1.copySync(dest1.path);
    }

    final src2 = File(r'C:\Users\Lenovo\.gemini\antigravity-ide\brain\49266b3a-adc8-4904-80a0-e3c780aa2b2e\freefire_crimson_bg_1785351290973.png');
    final dest2 = File(r'C:\Dhaval\flutter\Tournamnet App\Projects\TournaX\public\template_assets\slot_list_background\freefire_crimson_bg.png');
    if (src2.existsSync()) {
      dest2.parent.createSync(recursive: true);
      src2.copySync(dest2.path);
    }

    final src3 = File(r'C:\Users\Lenovo\.gemini\antigravity-ide\brain\49266b3a-adc8-4904-80a0-e3c780aa2b2e\dark_inferno_bg_1785351643314.png');
    final dest3 = File(r'C:\Dhaval\flutter\Tournamnet App\Projects\TournaX\public\template_assets\slot_list_background\dark_inferno_bg.png');
    if (src3.existsSync()) {
      dest3.parent.createSync(recursive: true);
      src3.copySync(dest3.path);
    }
  } catch (_) {}

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
      home: const TemplateManagerScreen(),
    );
  }
}
