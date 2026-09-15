import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/student.dart';
import '../services/attendance_service.dart';
import '../theme/app_colors.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  /// Imports students from a CSV file the user picks.
  /// Expected columns per row: id,name,program,cohort
  /// A header row (e.g. starting with "id" or "student id") is skipped.
  Future<void> importCsv() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final content = utf8.decode(bytes, allowMalformed: true);
    final rows = _parseCsv(content);

    int imported = 0;
    int skipped = 0;

    for (final parts in rows) {
      if (parts.isEmpty) continue;

      final lowerFirst = parts.first.trim().toLowerCase();
      if (lowerFirst == 'id' || lowerFirst == 'student id') continue;

      final id = parts.isNotEmpty ? parts[0].trim() : '';
      final name = parts.length > 1 ? parts[1].trim() : '';
      final program = parts.length > 2 ? parts[2].trim() : '';
      final cohort = parts.length > 3 ? parts[3].trim() : '';

      if (id.isEmpty || name.isEmpty) {
        skipped++;
        continue;
      }

      await AttendanceService.saveStudent(
        Student(id: id, name: name, program: program, cohort: cohort),
      );
      imported++;
    }

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported $imported student(s)'
            '${skipped > 0 ? ', skipped $skipped invalid row(s)' : ''}.',
          ),
        ),
      );
    }
  }


  List<List<String>> _parseCsv(String input) {
    final rows = <List<String>>[];
    final row = <String>[];
    final field = StringBuffer();
    var inQuotes = false;

    void finishField() {
      row.add(field.toString());
      field.clear();
    }

    void finishRow() {
      finishField();
      if (row.any((value) => value.trim().isNotEmpty)) {
        rows.add(List<String>.from(row));
      }
      row.clear();
    }

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '"') {
        if (inQuotes && i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        finishField();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        if (char == '\r' && i + 1 < input.length && input[i + 1] == '\n') {
          i++;
        }
        finishRow();
      } else {
        field.write(char);
      }
    }

    if (field.isNotEmpty || row.isNotEmpty) finishRow();
    return rows;
  }

  /// Shared dialog for both adding a new student and editing an existing
  /// one. Pass [existing] to pre-fill the fields and lock the ID field.
  Future<void> studentDialog({Student? existing}) async {
    final isEdit = existing != null;
    final id = TextEditingController(text: existing?.id ?? '');
    final name = TextEditingController(text: existing?.name ?? '');
    final program = TextEditingController(text: existing?.program ?? '');
    final cohort = TextEditingController(text: existing?.cohort ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Student' : 'Add Student'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: id,
                enabled: !isEdit,
                decoration: const InputDecoration(labelText: 'Student ID'),
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              TextField(
                controller: program,
                decoration: const InputDecoration(labelText: 'Primary program (optional)', helperText: 'Students are registered once and can be used across all programs.'),
              ),
              TextField(
                controller: cohort,
                decoration: const InputDecoration(labelText: 'Cohort'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final studentId = id.text.trim();
              final studentName = name.text.trim();

              if (studentId.isEmpty || studentName.isEmpty) return;

              if (!isEdit && AttendanceService.findStudent(studentId) != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('That Student ID already exists.'),
                    ),
                  );
                }
                return;
              }

              await AttendanceService.saveStudent(
                Student(
                  id: studentId,
                  name: studentName,
                  program: program.text.trim(),
                  cohort: cohort.text.trim(),
                  active: existing?.active ?? true,
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    id.dispose();
    name.dispose();
    program.dispose();
    cohort.dispose();
  }

  void showQr(Student student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: student.id,
              size: 240,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              'Student ID: ${student.id}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = AttendanceService.getStudents();
    final q = search.text.trim().toLowerCase();
    final students = all
        .where(
          (s) =>
              q.isEmpty ||
              s.id.toLowerCase().contains(q) ||
              s.name.toLowerCase().contains(q),
        )
        .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Import CSV',
                  icon: const Icon(Icons.upload_file),
                  onPressed: importCsv,
                ),
              ],
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text('No students registered yet.'),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final s = students[i];
                      return Dismissible(
                        key: ValueKey(s.id),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) async {
                          await AttendanceService.deleteStudent(s.id);
                          if (!mounted) return;
                          setState(() {});

                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('${s.name} deleted'),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () async {
                                  await AttendanceService.saveStudent(s);
                                  if (mounted) setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 24),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          child: ListTile(
                            onTap: () => studentDialog(existing: s),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.upshiftBlue,
                              child: Text(
                                s.id.isEmpty ? '?' : s.id[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${s.id} • ${s.program.isEmpty ? 'All programs' : s.program} • ${s.cohort}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Show QR',
                              icon: const Icon(
                                Icons.qr_code_2,
                                color: AppColors.upshiftOrangeDark,
                              ),
                              onPressed: () => showQr(s),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => studentDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('ADD STUDENT'),
      ),
    );
  }
}
