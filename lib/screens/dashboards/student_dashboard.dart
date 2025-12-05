import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: const Center(
        child: Text('Welcome, Student!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
