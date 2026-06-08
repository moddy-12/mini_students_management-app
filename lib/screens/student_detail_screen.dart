import 'package:flutter/material.dart';
import '../database/student_database.dart';
import 'registration_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final int index;
  const StudentDetailScreen({super.key, required this.index});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Map<String, dynamic> student;
  late TextEditingController _nameController;
  late TextEditingController _admController;
  late TextEditingController _courseController;

  @override
  void initState() {
    super.initState();
    student = Map<String, dynamic>.from(RegistrationScreen.students[widget.index]);
    _nameController = TextEditingController(text: student['name']);
    _admController = TextEditingController(text: student['adm']);
    _courseController = TextEditingController(text: student['course']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _admController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _admController.text.isEmpty || _courseController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final id = student['id'] as int?;
    final updated = {
      'name': _nameController.text,
      'adm': _admController.text,
      'course': _courseController.text,
    };

    if (id != null) {
      try {
        await StudentDatabase.updateStudent(id, updated);
        if (!mounted) return;
        RegistrationScreen.students[widget.index] = {
          'id': id,
          'name': updated['name'],
          'adm': updated['adm'],
          'course': updated['course'],
        };
        Navigator.pop(context, true);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update student')));
      }
    } else {
      RegistrationScreen.students[widget.index] = updated;
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    final id = student['id'] as int?;
    if (id != null) await StudentDatabase.deleteStudent(id);
    RegistrationScreen.students.removeAt(widget.index);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        actions: [
            IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete'),
                  content: const Text('Delete this student?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                    TextButton(onPressed: () { Navigator.pop(c); _delete(); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'student-avatar-${student['id'] ?? student['name']}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        (student['name'] ?? 'S').split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase(),
                        key: ValueKey(student['name']),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _admController,
              decoration: const InputDecoration(labelText: 'Admission', prefixIcon: Icon(Icons.badge)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course', prefixIcon: Icon(Icons.school)),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
