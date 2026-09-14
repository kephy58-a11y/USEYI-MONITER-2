import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/student.dart';
import '../services/attendance_service.dart';
import '../theme/app_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final controller = MobileScannerController();
  bool locked = false;
  bool torchOn = false;
  String message = 'Point the camera at a student QR code.';
  Student? lastStudent;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> toggleTorch() async {
    await controller.toggleTorch();
    setState(() => torchOn = !torchOn);
  }

  Future<void> handleCode(String? raw) async {
    if (locked || raw == null || raw.trim().isEmpty) return;

    setState(() => locked = true);

    final id = raw.trim();
    final student = AttendanceService.findStudent(id);

    if (student == null) {
      HapticFeedback.heavyImpact();
      setState(() {
        message = 'Student ID $id was not found.';
        lastStudent = null;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          locked = false;
          message = 'Point the camera at a student QR code.';
        });
      }
      return;
    }

    final added = await AttendanceService.markPresent(student.id);
    if (added) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }

    if (!mounted) return;
    setState(() {
      lastStudent = student;
      message = added
          ? '✓ Attendance recorded'
          : '⚠ Already marked present today';
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() {
        locked = false;
        message = 'Ready for the next student.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student'),
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            icon: Icon(torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: toggleTorch,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      handleCode(barcode.rawValue);
                      break;
                    }
                  },
                ),
                Center(
                  child: Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.upshiftOrange,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (lastStudent != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${lastStudent!.name} • ${lastStudent!.id}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
