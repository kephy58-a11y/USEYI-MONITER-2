import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

import '../services/attendance_service.dart';
import '../theme/app_colors.dart';

class AttendanceSheetScreen extends StatefulWidget {
  const AttendanceSheetScreen({super.key});

  @override
  State<AttendanceSheetScreen> createState() => _AttendanceSheetScreenState();
}

class _AttendanceSheetScreenState extends State<AttendanceSheetScreen> {
  DateTime selected = DateTime.now();

  Future<void> exportCsv() async {
    final csv = AttendanceService.attendanceCsv(selected);
    final day = DateFormat('yyyy-MM-dd').format(selected);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(utf8.encode(csv), mimeType: 'text/csv')],
        subject: 'Attendance Sheet – $day',
        fileNameOverrides: ['attendance_sheet_$day.csv'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = AttendanceService.attendanceForDay(selected);
    final presentIds = rows.map((r) => '${r['studentId']}').toSet();
    final students =
        AttendanceService.getStudents().where((s) => s.active).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Sheet'),
        actions: [
          IconButton(
            tooltip: 'Share / Export',
            icon: const Icon(Icons.ios_share),
            onPressed: exportCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('EEEE, d MMMM yyyy').format(selected)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selected,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => selected = picked);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.background,
                  ),
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Student ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Program')),
                    DataColumn(label: Text('Cohort')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: List.generate(students.length, (i) {
                    final s = students[i];
                    final present = presentIds.contains(s.id);
                    return DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(s.id)),
                        DataCell(Text(s.name)),
                        DataCell(Text(s.program)),
                        DataCell(Text(s.cohort)),
                        DataCell(
                          Text(
                            present ? 'PRESENT' : 'ABSENT',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: present
                                  ? AppColors.present
                                  : AppColors.absent,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${presentIds.length} present • '
              '${students.length - presentIds.length} absent • '
              '${students.length} total',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
