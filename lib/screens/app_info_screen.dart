import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_colors.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  static const String _shareText = '''USEYI Monitor

Upshift Youth Empowerment Initiative (USEYI)

USEYI Monitor is an offline-first attendance and program monitoring app.

Features:
• Student registration
• QR code attendance scanning
• Daily attendance sheets
• Programs and activities
• Outcomes and challenges
• Attendance reports
• CSV sharing/export
• Works offline with data stored on the phone

Developed by KEPHY TECH.
Version 1.1.0
''';

  Future<void> _share(BuildContext context) async {
    await SharePlus.instance.share(
      const ShareParams(
        text: _shareText,
        subject: 'USEYI Monitor - App Information',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Information'),
        actions: [
          IconButton(
            tooltip: 'Share app information',
            onPressed: () => _share(context),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.upshiftBlue.withValues(alpha: 0.08),
                    ),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'USEYI Monitor',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Upshift Youth Empowerment Initiative',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Powered by KEPHY TECH',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _InfoCard(
            icon: Icons.wifi_off_outlined,
            title: 'Offline first',
            text: 'Attendance, students, programs and monitoring records are stored locally on this phone. No internet connection is required for normal use.',
          ),
          const _InfoCard(
            icon: Icons.qr_code_scanner,
            title: 'QR attendance',
            text: 'Scan a student QR code to record attendance quickly, then review or correct the attendance sheet manually when needed.',
          ),
          const _InfoCard(
            icon: Icons.analytics_outlined,
            title: 'Monitoring & reports',
            text: 'Track programs, activities, outcomes and challenges, then generate attendance information for the dates you need.',
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.upshiftBlue),
              title: const Text('App version'),
              subtitle: const Text('1.1.0 • Offline Edition'),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _share(context),
            icon: const Icon(Icons.share),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text('SHARE APP INFORMATION'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share the app description and features with staff or partners.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.upshiftOrange.withValues(alpha: 0.14),
              foregroundColor: AppColors.upshiftOrangeDark,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(text, style: const TextStyle(height: 1.35, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
