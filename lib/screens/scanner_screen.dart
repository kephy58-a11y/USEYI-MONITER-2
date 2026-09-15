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

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController controller;
  bool locked = false;
  bool torchOn = false;
  String message = 'Point the camera at a student QR code.';
  Student? lastStudent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500,
      autoStart: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.start();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  Future<void> toggleTorch() async {
    try {
      await controller.toggleTorch();
      if (mounted) setState(() => torchOn = !torchOn);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The flashlight is not available.')),
        );
      }
    }
  }

  Future<void> handleCode(String? raw) async {
    if (locked || raw == null || raw.trim().isEmpty) return;

    final id = raw.trim();
    setState(() => locked = true);

    try {
      final student = AttendanceService.findStudent(id);
      if (student == null || !student.active) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          setState(() {
            message = student == null
                ? 'Student ID $id was not found.'
                : 'This student is inactive.';
            lastStudent = null;
          });
        }
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            locked = false;
            message = 'Ready for the next student.';
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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        message = 'Could not save attendance. Please try again.';
        lastStudent = null;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          locked = false;
          message = 'Ready for the next student.';
        });
      }
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
                    if (locked) return;
                    for (final barcode in capture.barcodes) {
                      final value = barcode.rawValue;
                      if (value != null && value.trim().isNotEmpty) {
                        handleCode(value);
                        break;
                      }
                    }
                  },
                  errorBuilder: (context, error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 56),
                            const SizedBox(height: 12),
                            const Text(
                              'Camera could not be started.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Allow camera permission for USEYI Monitor in Android Settings, then return to this screen.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => controller.start(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
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
