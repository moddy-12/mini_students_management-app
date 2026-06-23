import 'package:flutter/material.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List students = ["Moddy", "John", "Mary", "Brian"];

    return Scaffold(
      appBar: AppBar(title: const Text("Students")),

      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(students[index]),
              subtitle: const Text("BIT Student"),
            ),
          );
        },
      ),
    );
  }
}