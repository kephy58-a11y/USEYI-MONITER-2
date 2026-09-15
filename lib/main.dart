import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('students');
  await Hive.openBox('attendance');
  await Hive.openBox('settings');
  await Hive.openBox('programs');
  await Hive.openBox('activities');

  runApp(const UseyiMonitorApp());
}

class UseyiMonitorApp extends StatelessWidget {
  const UseyiMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.upshiftBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.upshiftBlue,
      onPrimary: Colors.white,
      secondary: AppColors.upshiftOrange,
      onSecondary: Colors.white,
      tertiary: AppColors.upshiftOrangeDark,
      surface: AppColors.surface,
    );

    return MaterialApp(
      title: 'USEYI Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.upshiftBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 1,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.upshiftBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.upshiftBlue,
            side: const BorderSide(color: AppColors.upshiftBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.upshiftOrange,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.upshiftOrange.withValues(alpha: 0.18),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.upshiftOrangeDark : Colors.grey,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? AppColors.upshiftOrangeDark : Colors.grey,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: inputBorder,
          focusedBorder: inputBorder.copyWith(
            borderSide: const BorderSide(
              color: AppColors.upshiftBlue,
              width: 2,
            ),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.upshiftBlue,
          selectionHandleColor: AppColors.upshiftBlue,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.upshiftOrange,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
