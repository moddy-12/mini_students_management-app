class Record {
  int? id;
  String name;
  String email;
  String course;

  Record({
    this.id,
    required this.name,
    required this.email,
    required this.course,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'course': course,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      course: map['course'],
    );
  }
}