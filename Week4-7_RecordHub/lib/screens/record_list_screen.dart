import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/record.dart';
import 'edit_record_screen.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

// Color mapping for courses
final Map<String, Color> courseColors = {
  'Computer Science': const Color(0xFF2563EB),
  'Engineering': const Color(0xFF059669),
  'Business': const Color(0xFFEF4444),
  'Arts': const Color(0xFF7C3AED),
  'Science': const Color(0xFFF97316),
  'Mathematics': const Color(0xFF8B5CF6),
  'Medicine': const Color(0xFFEC4899),
  'Law': const Color(0xFF06B6D4),
};

class _RecordListScreenState extends State<RecordListScreen> {
  List<Record> records = [];
  List<Record> filteredRecords = [];
  String _sortBy = 'name'; // name, course
  String? _filterCourse;
  Set<String> courses = {};

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final data = await DatabaseHelper.instance.getRecords();

    setState(() {
      records = data;
      courses = data.map((r) => r.course).toSet();
      applyFiltersAndSort();
    });
  }

  void applyFiltersAndSort() {
    setState(() {
      // Apply search filter
      var filtered = records.where((record) {
        final matchesSearch = searchController.text.isEmpty ||
            record.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            record.email
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            record.course
                .toLowerCase()
                .contains(searchController.text.toLowerCase());

        final matchesCourse =
            _filterCourse == null || record.course == _filterCourse;

        return matchesSearch && matchesCourse;
      }).toList();

      // Apply sorting
      if (_sortBy == 'name') {
        filtered.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortBy == 'course') {
        filtered.sort((a, b) => a.course.compareTo(b.course));
      }

      filteredRecords = filtered;
    });
  }

  Color _getCourseColor(String course) {
    return courseColors[course] ?? const Color(0xFF6366F1);
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF059669),
      const Color(0xFFEF4444),
      const Color(0xFF7C3AED),
      const Color(0xFFF97316),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseHelper.instance.deleteRecord(id);
    await loadRecords();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Record deleted successfully"),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
  }

  void _showDeleteConfirmation(Record record) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text("Delete Record"),
        content: Text(
          "Are you sure you want to delete ${record.name}'s record? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteRecord(record.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Records"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadRecords,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Box
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name, email, or course",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) => applyFiltersAndSort(),
            ),
            const SizedBox(height: 12),

            // Filters and Sort Row
            Row(
              children: [
                Expanded(
                  child: PopupMenuButton<String?>(
                    initialValue: _filterCourse,
                    onSelected: (value) {
                      setState(() => _filterCourse = value);
                      applyFiltersAndSort();
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: null,
                        child: Text('All Courses'),
                      ),
                      ...courses.map((course) {
                        return PopupMenuItem(
                          value: course,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getCourseColor(course),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(course),
                            ],
                          ),
                        );
                      }),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: _filterCourse != null
                            ? _getCourseColor(_filterCourse!)
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _filterCourse ?? 'Filter',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: PopupMenuButton<String>(
                    initialValue: _sortBy,
                    onSelected: (value) {
                      setState(() => _sortBy = value);
                      applyFiltersAndSort();
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem(
                        value: 'name',
                        child: Text('Sort by Name'),
                      ),
                      PopupMenuItem(
                        value: 'course',
                        child: Text('Sort by Course'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sort, size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _sortBy == 'name' ? 'Name' : 'Course',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Record Count
            if (filteredRecords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Showing ${filteredRecords.length} record${filteredRecords.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),

            // Records List
            filteredRecords.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Records Found',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchController.text.isEmpty &&
                                    _filterCourse == null
                                ? 'No student records yet. Add one to get started!'
                                : 'No records match your filters',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        final avatarColor = _getAvatarColor(index);
                        final courseColor = _getCourseColor(record.course);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: avatarColor,
                                      radius: 28,
                                      child: Text(
                                        record.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: courseColor
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              record.course,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: courseColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        record.email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit_outlined),
                                      label: const Text("Edit"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF2563EB),
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditRecordScreen(
                                              record: record,
                                            ),
                                          ),
                                        );
                                        loadRecords();
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete_outlined),
                                      label: const Text("Delete"),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFFEF4444),
                                      ),
                                      onPressed: () {
                                        _showDeleteConfirmation(record);
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
    searchController.dispose();
    super.dispose();
  }
}