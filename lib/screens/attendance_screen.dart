import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

import '../services/attendance_service.dart';
import '../theme/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selected = DateTime.now();
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> exportCsv() async {
    final csv = AttendanceService.attendanceCsv(selected);
    final day = DateFormat('yyyy-MM-dd').format(selected);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(utf8.encode(csv), mimeType: 'text/csv')],
        subject: 'Attendance – $day',
        fileNameOverrides: ['attendance_$day.csv'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = AttendanceService.attendanceForDay(selected);
    final presentIds = rows.map((r) => '${r['studentId']}').toSet();
    final q = search.text.trim().toLowerCase();
    final activeStudents = AttendanceService.getStudents()
        .where((s) => s.active)
        .where(
          (s) =>
              q.isEmpty ||
              s.id.toLowerCase().contains(q) ||
              s.name.toLowerCase().contains(q),
        )
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    DateFormat('EEE, d MMM yyyy').format(selected),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selected,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selected = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Export CSV',
                onPressed: exportCsv,
                icon: const Icon(Icons.ios_share),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by ID or name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '${presentIds.intersection(activeStudents.map((s) => s.id).toSet()).length} '
                  'present • '
                  '${activeStudents.length - presentIds.intersection(activeStudents.map((s) => s.id).toSet()).length} absent',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Tap a row to toggle present/absent manually.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              ...activeStudents.map((s) {
                final present = presentIds.contains(s.id);
                return ListTile(
                  onTap: () async {
                    if (present) {
                      await AttendanceService.setAbsent(s.id, date: selected);
                    } else {
                      await AttendanceService.setPresent(
                        s.id,
                        date: selected,
                      );
                    }
                    if (mounted) setState(() {});
                  },
                  leading: Icon(
                    present
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                    color: present ? AppColors.present : Colors.grey,
                  ),
                  title: Text(s.name),
                  subtitle: Text(s.id),
                  trailing: Text(
                    present ? 'PRESENT' : 'ABSENT',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
