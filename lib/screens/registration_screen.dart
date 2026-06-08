import 'package:flutter/material.dart';
import '../database/student_database.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static List<Map<String, dynamic>> students = [];

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState
    extends State<RegistrationScreen> {

  bool _isSaving = false;

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController admController =
      TextEditingController();

  final TextEditingController courseController =
      TextEditingController();

  Future<void> saveStudent() async {
    if (nameController.text.isEmpty ||
        admController.text.isEmpty ||
        courseController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all fields"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    final newStudent = {
      'name': nameController.text,
      'adm': admController.text,
      'course': courseController.text,
    };

    setState(() => _isSaving = true);

    try {
      final id = await StudentDatabase.insertStudent(newStudent);
      if (!mounted) return;

      RegistrationScreen.students.add({
        'id': id,
        'name': nameController.text,
        'adm': admController.text,
        'course': courseController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Student Added Successfully"),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      nameController.clear();
      admController.clear();
      courseController.clear();

      setState(() => _isSaving = false);
      Navigator.pop(context);
    } catch (e, st) {
      debugPrint('Failed to save student: $e');
      debugPrint('$st');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Failed to save student"), backgroundColor: Colors.red.shade600),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    admController.dispose();
    courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Student"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(56),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              "Student Registration",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
            ),

            const SizedBox(height: 8),

            Text(
              "Add a new student to the system",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // Name Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student Name",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter student name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Admission Number Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admission Number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: admController,
                    decoration: InputDecoration(
                      hintText: "Enter admission number",
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Course Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Course",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: courseController,
                    decoration: InputDecoration(
                      hintText: "Enter course name",
                      prefixIcon: const Icon(Icons.school),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : saveStudent,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.save, size: 20), SizedBox(width: 8), Text("Save Student", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 24),
                label: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                    color: Color(0xFF1E88E5),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}