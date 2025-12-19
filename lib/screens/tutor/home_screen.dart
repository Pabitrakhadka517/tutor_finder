import 'package:flutter/material.dart';

class TutorHomeScreen extends StatelessWidget {
  const TutorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                'Hello, Tutor!',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Here’s your overview for today',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              // 📊 Quick Stats with gradient
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _gradientStatCard(
                    'Upcoming Classes',
                    '3',
                    Colors.orange,
                    Colors.deepOrange,
                  ),
                  _gradientStatCard(
                    'Earnings',
                    '\$120',
                    Colors.green,
                    Colors.teal,
                  ),
                  _gradientStatCard(
                    'Messages',
                    '5',
                    Colors.blue,
                    Colors.indigo,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 🗓️ Upcoming Classes
              Text(
                'Upcoming Classes',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _classCard('Mathematics', 'Today, 4:00 PM', 'John Doe'),
              _classCard('English', 'Today, 6:00 PM', 'Jane Smith'),
              _classCard('Science', 'Tomorrow, 10:00 AM', 'Alan Brown'),

              const SizedBox(height: 25),

              // 📚 Recent Bookings
              Text(
                'Recent Bookings',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _bookingCard('Alice', 'Mathematics', 'Tomorrow, 4:00 PM'),
              _bookingCard('John', 'Science', 'Today, 6:00 PM'),
              _bookingCard('Jane', 'English', 'Today, 7:00 PM'),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Gradient stat card
  Widget _gradientStatCard(
    String title,
    String value,
    Color startColor,
    Color endColor,
  ) {
    return Container(
      width: 110,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: endColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 🏫 Class card with avatar
  Widget _classCard(String subject, String time, String student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(student[0]),
        ),
        title: Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$time • Student: $student'),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {},
          child: const Text('Start'),
        ),
      ),
    );
  }

  // 📚 Recent Booking card
  Widget _bookingCard(String student, String subject, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Text(student[0]),
        ),
        title: Text(
          '$student - $subject',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(time),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {},
          child: const Text('View'),
        ),
      ),
    );
  }
}
