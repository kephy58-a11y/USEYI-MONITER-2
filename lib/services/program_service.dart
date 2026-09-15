import 'package:hive_ce/hive.dart';
import '../models/program.dart';

class ProgramService {
  static Box get box => Hive.box('programs');

  static List<UseyiProgram> getPrograms() {
    return box.values.whereType<Map>().map((e) => UseyiProgram.fromMap(e)).where((p) => p.id.isNotEmpty).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  static Future<void> save(UseyiProgram program) async {
    await box.put(program.id, program.toMap());
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
  }
}
