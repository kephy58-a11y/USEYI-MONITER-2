import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../services/attendance_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime from = DateTime.now().subtract(const Duration(days: 6));
  DateTime to = DateTime.now();

  int _days() => to.difference(from).inDays + 1;

  int _presentTotal() {
    var total = 0;
    for (var i = 0; i < _days(); i++) {
      total += AttendanceService.presentCount(from.add(Duration(days: i)));
    }
    return total;
  }

  Future<void> _pick(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? from : to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isFrom) {
        from = picked;
        if (to.isBefore(from)) to = from;
      } else {
        to = picked;
        if (to.isBefore(from)) from = to;
      }
    });
  }

  String _cell(Object? value) {
    final text = '${value ?? ''}'.replaceAll('"', '""');
    return '"$text"';
  }

  Future<void> _export() async {
    final students = AttendanceService.getStudents()
        .where((student) => student.active)
        .toList();
    final buffer = StringBuffer(
      'Date,Student ID,Name,Program,Cohort,Status,Time\n',
    );

    for (var i = 0; i < _days(); i++) {
      final day = from.add(Duration(days: i));
      final rows = AttendanceService.attendanceForDay(day);
      final times = <String, String>{
        for (final row in rows)
          '${row['studentId']}': '${row['timestamp'] ?? ''}',
      };

      for (final student in students) {
        final present = times.containsKey(student.id);
        final timestamp = present ? times[student.id]! : '';
        final parsed = DateTime.tryParse(timestamp);
        final time = timestamp.isEmpty
            ? ''
            : (parsed?.toLocal().toIso8601String() ?? timestamp);

        buffer.writeln([
          _cell(DateFormat('yyyy-MM-dd').format(day)),
          _cell(student.id),
          _cell(student.name),
          _cell(student.program),
          _cell(student.cohort),
          _cell(present ? 'PRESENT' : 'ABSENT'),
          _cell(time),
        ].join(','));
      }
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            utf8.encode(buffer.toString()),
            mimeType: 'text/csv',
          ),
        ],
        subject: 'USEYI attendance report',
        fileNameOverrides: [
          'useyi_attendance_${DateFormat('yyyyMMdd').format(from)}_${DateFormat('yyyyMMdd').format(to)}.csv',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = AttendanceService.getStudents()
        .where((student) => student.active)
        .length;
    final present = _presentTotal();
    final possible = students * _days();
    final rate = possible == 0 ? 0 : (present / possible * 100).round();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Reports',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Review attendance across any date range and export the records.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(true),
                child: Text('From\n${DateFormat('d MMM yyyy').format(from)}'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(false),
                child: Text('To\n${DateFormat('d MMM yyyy').format(to)}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_days()} day range',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Text(
                  '$rate%',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text('attendance rate'),
                const SizedBox(height: 10),
                Text('$present attendance records recorded'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _export,
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('EXPORT CSV REPORT'),
        ),
      ],
    );
  }
}
