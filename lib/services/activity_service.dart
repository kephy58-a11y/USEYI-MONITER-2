import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class ActivityService {
  static Box get box => Hive.box('activities');

  static String dateKey([DateTime? date]) => DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

  static List<UseyiActivity> getActivities() {
    return box.values.whereType<Map>().map((e) => UseyiActivity.fromMap(e)).toList()
      ..sort((a, b) => '${b.date}${b.id}'.compareTo('${a.date}${a.id}'));
  }

  static Future<void> save(UseyiActivity activity) async {
    await box.put(activity.id, activity.toMap());
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
  }
}
