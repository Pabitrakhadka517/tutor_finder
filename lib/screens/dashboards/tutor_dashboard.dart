import 'package:flutter/material.dart';

// ✅ Import your tutor screens
import 'package:tutor_finder/screens/tutor/chat_screen.dart';
import 'package:tutor_finder/screens/tutor/home_screen.dart';
import 'package:tutor_finder/screens/tutor/profile_screen.dart';
import 'package:tutor_finder/screens/tutor/schedule_screen.dart';
import 'package:tutor_finder/screens/tutor/subject_screen.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TutorHomeScreen(),
    TutorScheduleScreen(),
    TutorSubjectScreen(),
    TutorChatScreen(),
    TutorProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor Dashboard')),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                'Tutor Menu',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            _drawerItem(Icons.home, 'Home', 0),
            _drawerItem(Icons.calendar_today, 'Schedule', 1),
            _drawerItem(Icons.menu_book, 'Subjects', 2),
            _drawerItem(Icons.chat, 'Chat', 3),
            _drawerItem(Icons.person, 'Profile', 4),
          ],
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Subjects',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}
