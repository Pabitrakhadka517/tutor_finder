import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Edit profile, settings & logout',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
