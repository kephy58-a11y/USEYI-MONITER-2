import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../theme/app_colors.dart';
import 'home_screen.dart';

/// Default PIN used the very first time the app runs, before staff
/// have changed it in Settings.
const String kDefaultPin = '1234';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final entered = TextEditingController();
  String? error;

  Box get _settings => Hive.box('settings');

  String get _storedPin => '${_settings.get('pin', defaultValue: kDefaultPin)}';

  void submit() {
    if (entered.text.trim() == _storedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => error = 'Wrong PIN, try again.');
      entered.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.upshiftBlue,
                child: Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'USEYI Monitor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const Text('Enter staff PIN to continue'),
              const SizedBox(height: 24),
              TextField(
                controller: entered,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 8,
                style: const TextStyle(fontSize: 22, letterSpacing: 6),
                decoration: InputDecoration(
                  counterText: '',
                  errorText: error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => submit(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Text('Unlock'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Default PIN is $kDefaultPin until changed in Settings.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
