import 'package:flutter/material.dart';

class StudentChatScreen extends StatelessWidget {
  const StudentChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Chat with your tutors',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
