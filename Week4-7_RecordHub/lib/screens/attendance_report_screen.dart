import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/database_helper.dart';
import '../models/attendance_record.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  bool _isLoading = true;
  List<AttendanceRecord> _records = [];
  DateTime? _startDate;
  DateTime? _endDate;

  String _dateKey(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadReport() async {
    final records = await DatabaseHelper.instance.getAttendanceRecords(
      startDate: _startDate == null ? null : _dateKey(_startDate!),
      endDate: _endDate == null ? null : _dateKey(_endDate!),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _startDate = pickedDate;
      if (_endDate != null && _endDate!.isBefore(_startDate!)) {
        _endDate = _startDate;
      }
    });

    await _loadReport();
  }

  Future<void> _pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() => _endDate = pickedDate);
    await _loadReport();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    await _loadReport();
  }

  String _formatDateLabel(DateTime? date) {
    if (date == null) {
      return 'Any date';
    }
    return _dateKey(date);
  }

  Future<void> _printReport() async {
    final pdf = await _buildPdfDocument();
    await Printing.layoutPdf(
      onLayout: (_) async => pdf,
      name: 'attendance_report.pdf',
    );
  }

  Future<void> _exportReport() async {
    final pdf = await _buildPdfDocument();
    await Printing.sharePdf(
      bytes: pdf,
      filename: 'attendance_report.pdf',
    );
  }

  Future<Uint8List> _buildPdfDocument() async {
    final document = pw.Document();
    final total = _records.length;
    final present = _records.where((record) => record.status == 'Present').length;
    final absent = _records.where((record) => record.status == 'Absent').length;
    final late = _records.where((record) => record.status == 'Late').length;
    final rate = total == 0 ? 0.0 : (present / total) * 100;

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
        ),
        build: (context) => [
          pw.Text(
            'Attendance Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Date range: ${_formatDateLabel(_startDate)} to ${_formatDateLabel(_endDate)}',
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _pdfStat('Total', total.toString()),
              _pdfStat('Present', present.toString()),
              _pdfStat('Absent', absent.toString()),
              _pdfStat('Late', late.toString()),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Attendance Rate: ${rate.toStringAsFixed(1)}%'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Student Breakdown',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Student', 'Course', 'Date', 'Status'],
            data: _records
                .map(
                  (record) => [
                    record.studentName,
                    record.course,
                    record.attendanceDate,
                    record.status,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _pdfStat(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _records.length;
    final present = _records.where((record) => record.status == 'Present').length;
    final absent = _records.where((record) => record.status == 'Absent').length;
    final late = _records.where((record) => record.status == 'Late').length;
    final rate = total == 0 ? 0.0 : (present / total) * 100;

    final studentStats = <String, Map<String, int>>{};
    for (final record in _records) {
      final stats = studentStats.putIfAbsent(
        record.studentName,
        () => {'Present': 0, 'Absent': 0, 'Late': 0, 'Total': 0},
      );
      stats[record.status] = (stats[record.status] ?? 0) + 1;
      stats['Total'] = (stats['Total'] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'print') {
                _printReport();
              } else if (value == 'export') {
                _exportReport();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'print',
                child: Text('Print report'),
              ),
              PopupMenuItem(
                value: 'export',
                child: Text('Export PDF'),
              ),
            ],
          ),
          IconButton(
            onPressed: _loadReport,
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
                    'Attendance summary across all saved records.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date Range Filter',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickStartDate,
                                      icon: const Icon(Icons.date_range),
                                      label: Text('From ${_formatDateLabel(_startDate)}'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickEndDate,
                                      icon: const Icon(Icons.event),
                                      label: Text('To ${_formatDateLabel(_endDate)}'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: (_startDate == null && _endDate == null)
                                      ? null
                                      : _clearFilters,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear filters'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildStatCard(context, 'Total', total.toString(), const Color(0xFF2563EB)),
                      _buildStatCard(context, 'Present', present.toString(), const Color(0xFF059669)),
                      _buildStatCard(context, 'Absent', absent.toString(), const Color(0xFFEF4444)),
                      _buildStatCard(context, 'Late', late.toString(), const Color(0xFFF97316)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Rate',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${rate.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Student Breakdown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          _startDate == null && _endDate == null
                              ? 'No attendance data yet.'
                              : 'No attendance data for the selected date range.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ),
                    )
                  else
                    ...studentStats.entries.map((entry) {
                      final stats = entry.value;
                      final totalSessions = stats['Total'] ?? 0;
                      final presentCount = stats['Present'] ?? 0;
                      final absentCount = stats['Absent'] ?? 0;
                      final lateCount = stats['Late'] ?? 0;
                      final percentage = totalSessions == 0
                          ? 0.0
                          : (presentCount / totalSessions) * 100;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _metricChip('Present', presentCount, const Color(0xFF059669)),
                                  _metricChip('Absent', absentCount, const Color(0xFFEF4444)),
                                  _metricChip('Late', lateCount, const Color(0xFFF97316)),
                                  _metricChip('Total', totalSessions, const Color(0xFF2563EB)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}