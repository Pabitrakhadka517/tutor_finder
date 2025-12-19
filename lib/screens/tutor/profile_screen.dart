import 'package:flutter/material.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Tutor Profile', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
