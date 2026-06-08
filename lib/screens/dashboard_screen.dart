import 'package:flutter/material.dart';

import '../database/student_database.dart';
import 'registration_screen.dart';
import 'student_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortField = 'name';
  bool _ascending = true;
  String? _courseFilter;

  @override
  void initState() {
    super.initState();
    _reloadStudents();
  }

  Future<void> _reloadStudents() async {
    final rows = await StudentDatabase.getAllStudents();
    if (!mounted) return;
    RegistrationScreen.students = rows.map((r) => {
          'id': r['id'],
          'name': r['name'],
          'adm': r['admission'],
          'course': r['course'],
        }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportCsv() async {
    try {
      final path = await StudentDatabase.exportCsv();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported CSV to: $path')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export failed')));
    }
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending;
      } else {
        _sortField = field;
        _ascending = true;
      }
    });
  }

  Future<void> _onRefresh() async {
    await _reloadStudents();
  }

  void _showDeleteDialog(BuildContext context, int index) {
    final student = RegistrationScreen.students[index];
    final id = student['id'] as int?;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: const Text('Are you sure you want to delete this student?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (id != null) await StudentDatabase.deleteStudent(id);
                if (!mounted) return;
                RegistrationScreen.students.removeAt(index);
                setState(() {});
                Navigator.pop(this.context);
                ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Student deleted successfully')));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var students = RegistrationScreen.students.cast<Map<String, dynamic>>();

    if (_query.isNotEmpty) {
      students = students.where((s) {
        final q = _query.toLowerCase();
        return (s['name'] as String).toLowerCase().contains(q) || (s['adm'] as String).toLowerCase().contains(q) || (s['course'] as String).toLowerCase().contains(q);
      }).toList();
    }

    if (_courseFilter != null && _courseFilter!.isNotEmpty) {
      students = students.where((s) => (s['course'] as String) == _courseFilter).toList();
    }

    students.sort((a, b) {
      final A = (a[_sortField] ?? '').toString().toLowerCase();
      final B = (b[_sortField] ?? '').toString().toLowerCase();
      return _ascending ? A.compareTo(B) : B.compareTo(A);
    });

    final courses = RegistrationScreen.students.map((s) => s['course'] as String).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            onPressed: _exportCsv,
            icon: const Icon(Icons.download),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'name' || v == 'adm' || v == 'course') _setSort(v);
              if (v == 'clear_filter') setState(() => _courseFilter = null);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'adm', child: Text('Sort by Admission')),
              const PopupMenuItem(value: 'course', child: Text('Sort by Course')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'clear_filter', child: Text('Clear Course Filter')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Center(child: Text('${students.length}')), 
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E88E5), Color(0xFF1565C0)]),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Student Management', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ],
              ),
            ),
            const ListTile(leading: Icon(Icons.home, color: Color(0xFF1E88E5)), title: Text('Dashboard')),
            const ListTile(leading: Icon(Icons.people, color: Color(0xFF1E88E5)), title: Text('Students')),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => const RegistrationScreen()));
          await _reloadStudents();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),

      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search'),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _courseFilter,
                  hint: const Text('Filter'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All')) as DropdownMenuItem<String?>,
                    ...courses.map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  ],
                  onChanged: (v) => setState(() => _courseFilter = (v == '' ? null : v)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Stats card with animated count
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E88E5), Color(0xFF1565C0)])),
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total Students', style: TextStyle(color: Colors.white.withAlpha(230))),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Text('${RegistrationScreen.students.length}', key: ValueKey<int>(RegistrationScreen.students.length), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.people, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // List header
            Text('Registered Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
            const SizedBox(height: 8),

            // Students
            ...students.map((student) {
              final index = RegistrationScreen.students.indexWhere((s) => s['id'] == student['id']);
              final initials = (student['name'] as String).split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
              final id = student['id'] as int?;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(id ?? student['name']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    final messenger = ScaffoldMessenger.of(context);
                    // perform delete
                    if (id != null) await StudentDatabase.deleteStudent(id);
                    final removed = RegistrationScreen.students.removeAt(index);
                    if (!mounted) return true;
                    setState(() {});

                    messenger.showSnackBar(SnackBar(
                      content: const Text('Student deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          // re-insert
                          await StudentDatabase.insertStudent({'name': removed['name'], 'adm': removed['adm'], 'course': removed['course']});
                          if (!mounted) return;
                          await _reloadStudents();
                        },
                      ),
                    ));

                    return true;
                  },
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () async {
                        final changed = await Navigator.push(context, MaterialPageRoute(builder: (c) => StudentDetailScreen(index: index)));
                        if (changed == true) await _reloadStudents();
                      },
                      leading: Hero(tag: 'student-avatar-${id ?? student['name']}', child: CircleAvatar(radius: 28, backgroundColor: const Color(0xFF1E88E5), child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
                      title: Text(student['name'] ?? ''),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 6), Text(student['adm'] ?? ''), Text(student['course'] ?? '')]),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _showDeleteDialog(context, index)),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
