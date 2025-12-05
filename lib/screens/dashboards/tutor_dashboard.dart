import 'package:flutter/material.dart';

class TutorDashboard extends StatelessWidget {
  const TutorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Dashboard'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: const Center(
        child: Text('Welcome, Tutor!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
