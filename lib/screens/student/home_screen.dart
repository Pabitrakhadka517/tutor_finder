import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Greeting
              Text(
                'Hello, Student!',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Find the best tutors for your needs',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),

              const SizedBox(height: 20),

              // 🔍 Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search tutors, subjects...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🏷️ Categories
              Text(
                'Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryCard('Math', Icons.calculate, Colors.orange),
                    _categoryCard('Science', Icons.science, Colors.green),
                    _categoryCard('English', Icons.menu_book, Colors.blue),
                    _categoryCard('Coding', Icons.computer, Colors.purple),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 👩‍🏫 Recommended Tutors
              Text(
                'Recommended Tutors',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  _tutorCard(
                    name: 'Mr. John Doe',
                    subject: 'Mathematics',
                    rating: 4.8,
                    imageUrl: 'https://i.pravatar.cc/150?img=1',
                  ),
                  _tutorCard(
                    name: 'Ms. Jane Smith',
                    subject: 'English',
                    rating: 4.7,
                    imageUrl: 'https://i.pravatar.cc/150?img=2',
                  ),
                  _tutorCard(
                    name: 'Mr. Alan Brown',
                    subject: 'Science',
                    rating: 4.9,
                    imageUrl: 'https://i.pravatar.cc/150?img=3',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📅 Upcoming Classes
              Text(
                'Upcoming Classes',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _scheduleCard('Mathematics', 'Today, 4:00 PM', 'Mr. John Doe'),
              _scheduleCard('English', 'Tomorrow, 10:00 AM', 'Ms. Jane Smith'),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Category card widget
  Widget _categoryCard(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // 🎓 Tutor card widget
  Widget _tutorCard({
    required String name,
    required String subject,
    required double rating,
    required String imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$subject • ⭐ $rating'),
        trailing: ElevatedButton(onPressed: () {}, child: const Text('Book')),
      ),
    );
  }

  // 📅 Schedule card widget
  Widget _scheduleCard(String subject, String time, String tutor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.event, color: Colors.blue),
        title: Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$time • $tutor'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {},
        ),
      ),
    );
  }
}
