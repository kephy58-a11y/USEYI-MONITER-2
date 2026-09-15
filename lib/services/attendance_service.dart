import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

import '../models/student.dart';

class AttendanceService {
  static final Box _students = Hive.box('students');
  static final Box _attendance = Hive.box('attendance');

  static String dateKey([DateTime? date]) =>
      DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

  static List<Student> getStudents() {
    return _students.values
        .whereType<Map>()
        .map((e) => Student.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  static Student? findStudent(String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    final value = _students.get(normalized);
    if (value == null || value is! Map) return null;
    return Student.fromMap(Map<String, dynamic>.from(value));
  }

  static Future<void> saveStudent(Student student) async {
    final normalizedId = student.id.trim();
    if (normalizedId.isEmpty) throw ArgumentError('Student ID is required.');
    await _students.put(normalizedId, student.copyWith(id: normalizedId).toMap());
  }

  static Future<void> deleteStudent(String id) async {
    await _students.delete(id.trim());
  }

  static bool isPresent(String studentId, [DateTime? date]) {
    return _attendance.get('${dateKey(date)}|${studentId.trim()}') != null;
  }

  static Future<bool> markPresent(String studentId, {DateTime? time}) async {
    final id = studentId.trim();
    final student = findStudent(id);
    if (student == null || !student.active) return false;

    final now = time ?? DateTime.now();
    final day = dateKey(now);
    final key = '$day|$id';
    if (_attendance.get(key) != null) return false;

    await _attendance.put(key, {
      'studentId': id,
      'date': day,
      'timestamp': now.toIso8601String(),
    });
    return true;
  }

  static List<Map<String, dynamic>> attendanceForDay([DateTime? date]) {
    final day = dateKey(date);
    final activeIds = getStudents()
        .where((student) => student.active)
        .map((student) => student.id)
        .toSet();
    final rows = <Map<String, dynamic>>[];

    for (final value in _attendance.values) {
      if (value is! Map) continue;
      final map = Map<String, dynamic>.from(value);
      final id = '${map['studentId'] ?? ''}';
      if (map['date'] == day && activeIds.contains(id)) {
        rows.add(map);
      }
    }

    rows.sort((a, b) => '${a['timestamp']}'.compareTo('${b['timestamp']}'));
    return rows;
  }

  static int presentCount([DateTime? date]) => attendanceForDay(date).length;

  static int absentCount([DateTime? date]) {
    final active = getStudents().where((s) => s.active).length;
    return (active - presentCount(date)).clamp(0, active);
  }

  static Future<void> setPresent(String studentId, {DateTime? date}) async {
    final id = studentId.trim();
    final student = findStudent(id);
    if (student == null || !student.active) return;

    final chosen = date ?? DateTime.now();
    final day = dateKey(chosen);
    final key = '$day|$id';
    if (_attendance.get(key) != null) return;

    await _attendance.put(key, {
      'studentId': id,
      'date': day,
      'timestamp': chosen.toIso8601String(),
    });
  }

  static Future<void> setAbsent(String studentId, {DateTime? date}) async {
    await _attendance.delete('${dateKey(date)}|${studentId.trim()}');
  }

  static String csvCell(Object? value) {
    final text = '${value ?? ''}';
    return '"${text.replaceAll('"', '""')}"';
  }

  static String attendanceCsv([DateTime? date]) {
    final day = dateKey(date);
    final rows = attendanceForDay(date);
    final presentMap = {
      for (final row in rows) '${row['studentId']}': '${row['timestamp']}',
    };
    final students = getStudents().where((s) => s.active).toList();

    final buffer = StringBuffer();
    buffer.writeln('Date,Student ID,Name,Program,Cohort,Status,Time');
    for (final student in students) {
      final present = presentMap.containsKey(student.id);
      final timestamp = present ? presentMap[student.id]! : '';
      final time = timestamp.isEmpty
          ? ''
          : DateTime.tryParse(timestamp)?.toLocal().toIso8601String() ?? timestamp;
      buffer.writeln([
        csvCell(day),
        csvCell(student.id),
        csvCell(student.name),
        csvCell(student.program),
        csvCell(student.cohort),
        csvCell(present ? 'PRESENT' : 'ABSENT'),
        csvCell(time),
      ].join(','));
    }
    return buffer.toString();
  }
}
