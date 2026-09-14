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
        .map((e) => Student.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  static Student? findStudent(String id) {
    final value = _students.get(id);
    if (value == null) return null;
    return Student.fromMap(Map<String, dynamic>.from(value));
  }

  static Future<void> saveStudent(Student student) async {
    await _students.put(student.id, student.toMap());
  }

  static Future<void> deleteStudent(String id) async {
    await _students.delete(id);
  }

  static bool isPresent(String studentId, [DateTime? date]) {
    final day = dateKey(date);
    return _attendance.get('$day|$studentId') != null;
  }

  static Future<bool> markPresent(String studentId, {DateTime? time}) async {
    final now = time ?? DateTime.now();
    final day = dateKey(now);
    final key = '$day|$studentId';

    if (_attendance.get(key) != null) return false;

    await _attendance.put(key, {
      'studentId': studentId,
      'date': day,
      'timestamp': now.toIso8601String(),
    });
    return true;
  }

  static List<Map<String, dynamic>> attendanceForDay([DateTime? date]) {
    final day = dateKey(date);
    final rows = <Map<String, dynamic>>[];

    for (final value in _attendance.values) {
      final map = Map<String, dynamic>.from(value);
      if (map['date'] == day) rows.add(map);
    }

    rows.sort(
      (a, b) => '${a['timestamp']}'.compareTo('${b['timestamp']}'),
    );
    return rows;
  }

  static int presentCount([DateTime? date]) => attendanceForDay(date).length;

  static int absentCount([DateTime? date]) {
    final active = getStudents().where((s) => s.active).length;
    return (active - presentCount(date)).clamp(0, active);
  }

  /// Manually mark a student present for [date] (defaults to today).
  /// Used for the tap-to-toggle override in the Attendance tab.
  static Future<void> setPresent(String studentId, {DateTime? date}) async {
    final day = dateKey(date);
    final key = '$day|$studentId';
    if (_attendance.get(key) != null) return;

    await _attendance.put(key, {
      'studentId': studentId,
      'date': day,
      'timestamp': (date ?? DateTime.now()).toIso8601String(),
    });
  }

  /// Manually mark a student absent for [date] by removing their
  /// attendance record for that day.
  static Future<void> setAbsent(String studentId, {DateTime? date}) async {
    final day = dateKey(date);
    await _attendance.delete('$day|$studentId');
  }

  /// Builds a CSV string of attendance for [date]: one row per active
  /// student with their present/absent status for that day.
  static String attendanceCsv([DateTime? date]) {
    final day = dateKey(date);
    final rows = attendanceForDay(date);
    final presentMap = {
      for (final r in rows) '${r['studentId']}': '${r['timestamp']}',
    };
    final students = getStudents().where((s) => s.active).toList();

    final buffer = StringBuffer();
    buffer.writeln('Date,Student ID,Name,Program,Cohort,Status,Time');
    for (final s in students) {
      final present = presentMap.containsKey(s.id);
      final time = present ? presentMap[s.id]! : '';
      buffer.writeln(
        '$day,${s.id},"${s.name}","${s.program}","${s.cohort}",'
        '${present ? 'PRESENT' : 'ABSENT'},$time',
      );
    }
    return buffer.toString();
  }
}
