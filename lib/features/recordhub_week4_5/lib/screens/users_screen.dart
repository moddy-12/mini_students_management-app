import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = ApiService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API Users"),
      ),
      body: FutureBuilder<List<User>>(
        future: users,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final userList = snapshot.data!;

          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {

              final user = userList[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.id.toString()),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                ),
              );
            },
          );
        },
      ),
    );
  }
}