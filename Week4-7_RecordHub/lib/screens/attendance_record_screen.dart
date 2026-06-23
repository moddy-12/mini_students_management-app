import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/attendance_record.dart';

class AttendanceRecordScreen extends StatefulWidget {
  const AttendanceRecordScreen({super.key});

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  bool _isLoading = true;
  List<AttendanceRecord> _records = [];
  String _searchQuery = '';
  String? _selectedStatus;

  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusOptions = const ['Present', 'Absent', 'Late'];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.instance.getAttendanceRecords();

    if (!mounted) {
      return;
    }

    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  List<AttendanceRecord> get _filteredRecords {
    return _records.where((record) {
      final matchesSearch = _searchQuery.isEmpty ||
          record.studentName.toLowerCase().contains(_searchQuery) ||
          record.course.toLowerCase().contains(_searchQuery) ||
          record.attendanceDate.contains(_searchQuery);
      final matchesStatus =
          _selectedStatus == null || record.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF059669);
      case 'Absent':
        return const Color(0xFFEF4444);
      case 'Late':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadRecords,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search name, course, or date',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Statuses'),
                            ),
                            ..._statusOptions.map(
                              (status) => DropdownMenuItem<String?>(
                                value: status,
                                child: Text(status),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedStatus = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredRecords.isEmpty
                        ? Center(
                            child: Text(
                              'No attendance records found.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredRecords.length,
                            itemBuilder: (context, index) {
                              final record = _filteredRecords[index];
                              final color = _statusColor(record.status);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color,
                                    child: Text(
                                      record.studentName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(record.studentName),
                                  subtitle: Text(
                                    '${record.course} • ${record.attendanceDate}',
                                  ),
                                  trailing: Chip(
                                    label: Text(record.status),
                                    backgroundColor: color.withValues(alpha: 0.12),
                                    labelStyle: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}