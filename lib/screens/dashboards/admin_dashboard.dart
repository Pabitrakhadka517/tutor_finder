import 'package:flutter/material.dart';
import 'package:tutor_finder/screens/admin/home_screen.dart';
import 'package:tutor_finder/screens/admin/profile_screen.dart';
import 'package:tutor_finder/screens/admin/reports_screen.dart';
import 'package:tutor_finder/screens/admin/requests_screen.dart';
import 'package:tutor_finder/screens/admin/users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeScreen(),
    const AdminUsersScreen(),
    const AdminRequestsScreen(),
    const AdminReportsScreen(),
    const AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Menu',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Home'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Users'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Requests'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Profile'),
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
        ],
      ),
    );
  }
}
