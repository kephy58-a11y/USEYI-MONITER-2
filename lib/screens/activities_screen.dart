import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../services/program_service.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});
  @override State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}
class _ActivitiesScreenState extends State<ActivitiesScreen> {
  Future<void> _add() async {
    final title = TextEditingController(); final outcome = TextEditingController(); final challenge = TextEditingController(); final notes = TextEditingController();
    String program = ProgramService.getPrograms().isNotEmpty ? ProgramService.getPrograms().first.name : 'General';
    final key = GlobalKey<FormState>();
    await showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialog) => AlertDialog(
      title: const Text('Record activity'),
      content: Form(key: key, child: SingleChildScrollView(child: Column(children: [
        TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Activity / session'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter an activity' : null),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: program, decoration: const InputDecoration(labelText: 'Program'), items: [if (ProgramService.getPrograms().isEmpty) const DropdownMenuItem(value: 'General', child: Text('General')), ...ProgramService.getPrograms().map((p) => DropdownMenuItem(value: p.name, child: Text(p.name)))], onChanged: (v) { if (v != null) setDialog(() => program = v); }),
        const SizedBox(height: 10), TextField(controller: outcome, maxLines: 2, decoration: const InputDecoration(labelText: 'Outcome / achievement')),
        const SizedBox(height: 10), TextField(controller: challenge, maxLines: 2, decoration: const InputDecoration(labelText: 'Challenge')),
        const SizedBox(height: 10), TextField(controller: notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes')),
      ])),),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { if (!key.currentState!.validate()) return; await ActivityService.save(UseyiActivity(id: 'activity_${DateTime.now().microsecondsSinceEpoch}', date: ActivityService.dateKey(), program: program, title: title.text.trim(), outcome: outcome.text.trim(), challenge: challenge.text.trim(), notes: notes.text.trim())); if (context.mounted) Navigator.pop(context); if (mounted) setState(() {}); }, child: const Text('Save'))],
    )));
    title.dispose(); outcome.dispose(); challenge.dispose(); notes.dispose();
  }
  @override Widget build(BuildContext context) { final items = ActivityService.getActivities(); return Scaffold(body: items.isEmpty ? const Center(child: Text('No activities recorded yet.')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: items.length, itemBuilder: (_, i) { final a = items[i]; return Card(child: ListTile(leading: const Icon(Icons.event_note_outlined), title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${a.program} • ${DateFormat('d MMM yyyy').format(DateTime.tryParse(a.date) ?? DateTime.now())}\n${a.outcome.isEmpty ? 'No outcome entered' : a.outcome}'), isThreeLine: true, trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await ActivityService.delete(a.id); if (mounted) setState(() {}); }))); }), floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('ACTIVITY'))); }
}
