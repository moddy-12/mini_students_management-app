class Student {
  int? id;
  String name;
  String admission;
  String course;

  Student({
    this.id,
    required this.name,
    required this.admission,
    required this.course,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'admission': admission,
      'course': course,
    };
  }
}