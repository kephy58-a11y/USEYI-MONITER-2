import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../theme/app_colors.dart';
import 'home_screen.dart';

const String kDefaultPin = '1234';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final entered = TextEditingController();
  String? error;
  Box get settings => Hive.box('settings');
  String get storedPin => '${settings.get('pin', defaultValue: kDefaultPin)}';

  void unlock() {
    if (entered.text.trim() == storedPin) {
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
  void dispose() {
    entered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon/app_icon.png', height: 110),
                const SizedBox(height: 14),
                const Text(
                  'USEYI Monitor',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text('Offline attendance & program monitoring'),
                const SizedBox(height: 26),
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
                    labelText: 'Staff PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  onSubmitted: (_) => unlock(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: unlock,
                    icon: const Icon(Icons.lock_open),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('UNLOCK APP'),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Default PIN: 1234. Change it after opening the app.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
