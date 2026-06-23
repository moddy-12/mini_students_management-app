import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/attendance_record.dart';
import '../models/record.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _StudentAttendanceDraft {
  _StudentAttendanceDraft({
    required this.record,
    required this.status,
  });

  final Record record;
  String status;
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final List<String> _statusOptions = const ['Present', 'Absent', 'Late'];
  final DateTime _today = DateTime.now();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedCourse;
  DateTime _selectedDate = DateTime.now();
  List<Record> _records = [];
  List<_StudentAttendanceDraft> _drafts = [];

  List<String> get _courseOptions {
    final courses = _records.map((record) => record.course).toSet().toList();
    courses.sort();
    return courses;
  }

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  String _dateKey(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.instance.getRecords();
    final courses = records.map((record) => record.course).toSet().toList()..sort();

    if (!mounted) {
      return;
    }

    setState(() {
      _records = records;
      _selectedCourse ??= courses.isNotEmpty ? courses.first : null;
      _buildDrafts();
      _isLoading = false;
    });
  }

  void _buildDrafts() {
    final filtered = _selectedCourse == null
        ? _records
        : _records.where((record) => record.course == _selectedCourse).toList();

    final existingStatuses = {
      for (final draft in _drafts) draft.record.id: draft.status,
    };

    _drafts = filtered
        .where((record) => record.id != null)
        .map(
          (record) => _StudentAttendanceDraft(
            record: record,
            status: existingStatuses[record.id] ?? 'Present',
          ),
        )
        .toList();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_today.year - 1),
      lastDate: DateTime(_today.year + 1),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _saveAttendance() async {
    if (_drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add student records before marking attendance.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateKey = _dateKey(_selectedDate);
      for (final draft in _drafts) {
        final record = draft.record;
        await DatabaseHelper.instance.saveAttendance(
          AttendanceRecord(
            recordId: record.id!,
            studentName: record.name,
            course: record.course,
            attendanceDate: dateKey,
            status: draft.status,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully.'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadRecords,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mark attendance for the selected course and date.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Attendance Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(_dateKey(_selectedDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCourse,
                          decoration: InputDecoration(
                            labelText: 'Course',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _courseOptions
                              .map(
                                (course) => DropdownMenuItem(
                                  value: course,
                                  child: Text(course),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCourse = value;
                              _buildDrafts();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_drafts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'No students found for this course.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ),
                    )
                  else
                    ..._drafts.map(
                      (draft) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF2563EB),
                                    child: Text(
                                      draft.record.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          draft.record.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          draft.record.course,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: _statusOptions.map((status) {
                                  final isSelected = draft.status == status;
                                  return ChoiceChip(
                                    label: Text(status),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        draft.status = status;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveAttendance,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(_isSaving ? 'Saving...' : 'Save Attendance'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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