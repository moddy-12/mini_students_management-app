import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 40, backgroundColor: Theme.of(context).colorScheme.primary, child: const Icon(Icons.person, color: Colors.white)),
                const SizedBox(height: 12),
                Text('Moddy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Student UI/UX Project', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 14),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Edit Profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}