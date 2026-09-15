import 'package:flutter/material.dart';
import '../models/program.dart';
import '../services/program_service.dart';
import '../theme/app_colors.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});
  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  Future<void> _edit([UseyiProgram? existing]) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final description = TextEditingController(text: existing?.description ?? '');
    final formKey = GlobalKey<FormState>();
    await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(existing == null ? 'Add program' : 'Edit program'),
      content: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Program name'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null),
        const SizedBox(height: 10),
        TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (optional)')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          final id = existing?.id ?? 'program_${DateTime.now().microsecondsSinceEpoch}';
          await ProgramService.save(UseyiProgram(id: id, name: name.text.trim(), description: description.text.trim(), active: existing?.active ?? true));
          if (context.mounted) Navigator.pop(context);
          if (mounted) setState(() {});
        }, child: const Text('Save')),
      ],
    ));
    name.dispose(); description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programs = ProgramService.getPrograms();
    return Scaffold(
      body: programs.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.folder_copy_outlined, size: 64, color: AppColors.upshiftBlue),
              const SizedBox(height: 14),
              const Text('No programs yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Add your USEYI programs here. Every registered student remains available to all programs.', textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: _edit, icon: const Icon(Icons.add), label: const Text('ADD PROGRAM')),
            ])))
          : ListView.builder(padding: const EdgeInsets.all(16), itemCount: programs.length, itemBuilder: (context, i) {
              final p = programs[i];
              return Card(child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.upshiftOrange.withValues(alpha: .15), child: const Icon(Icons.folder_outlined, color: AppColors.upshiftOrangeDark)),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(p.description.isEmpty ? 'All registered students can be used in this program.' : p.description),
                trailing: PopupMenuButton<String>(onSelected: (v) async {
                  if (v == 'edit') await _edit(p);
                  if (v == 'delete') { await ProgramService.delete(p.id); if (mounted) setState(() {}); }
                }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]),
              ));
            }),
      floatingActionButton: programs.isNotEmpty ? FloatingActionButton.extended(onPressed: _edit, icon: const Icon(Icons.add), label: const Text('PROGRAM')) : null,
    );
  }
}
