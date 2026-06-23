class AttendanceRecord {
  int? id;
  int recordId;
  String studentName;
  String course;
  String attendanceDate;
  String status;
  String createdAt;

  AttendanceRecord({
    this.id,
    required this.recordId,
    required this.studentName,
    required this.course,
    required this.attendanceDate,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record_id': recordId,
      'student_name': studentName,
      'course': course,
      'attendance_date': attendanceDate,
      'status': status,
      'created_at': createdAt,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      recordId: map['record_id'] as int,
      studentName: map['student_name'] as String,
      course: map['course'] as String,
      attendanceDate: map['attendance_date'] as String,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}