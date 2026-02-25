import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/socket/socket_service.dart';
import '../../../admin/presentation/pages/admin_users_page.dart';
import '../../../admin/presentation/pages/announcements_page.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../booking/presentation/pages/booking_list_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../study/presentation/pages/study_resources_page.dart';
import '../../../transaction/presentation/pages/transaction_history_page.dart';
import '../../../tutor/presentation/pages/tutor_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'wallet_page.dart';
import 'admin_dashboard_page.dart';
import 'student_dashboard_page.dart';
import 'tutor_dashboard_page.dart';

/// Role-based dashboard shell that wraps the appropriate dashboard view
/// based on the current user's role.
///
/// Each role gets:
/// - A different dashboard content page
/// - Role-specific sidebar/drawer navigation
/// - Role-specific bottom navigation bar
/// - Role-specific app bar title and theming
class RoleBasedDashboardShell extends ConsumerStatefulWidget {
  const RoleBasedDashboardShell({super.key});

  @override
  ConsumerState<RoleBasedDashboardShell> createState() =>
      _RoleBasedDashboardShellState();
}

class _RoleBasedDashboardShellState
    extends ConsumerState<RoleBasedDashboardShell> {
  int _selectedIndex = 0;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = ref.read(socketServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationNotifierProvider.notifier).fetchUnreadCount();
      _initSocketNotifications();
    });
  }

  Future<void> _initSocketNotifications() async {
    await _socketService.connect();
    _socketService.onNewNotification((data) {
      if (!mounted) return;
      if (data is Map<String, dynamic>) {
        ref
            .read(notificationNotifierProvider.notifier)
            .addIncomingNotification(data);
      }
    });
  }

  @override
  void dispose() {
    _socketService.off('new_notification');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final role = user?.role ?? UserRole.student;
    final notificationState = ref.watch(notificationNotifierProvider);
    final unreadCount = notificationState.unreadCount;

    return Scaffold(
      backgroundColor: _backgroundColorForRole(role),
      appBar: _buildAppBar(role, user, unreadCount),
      drawer: _buildDrawer(context, user, role),
      body: _buildBody(role),
      bottomNavigationBar: _buildBottomNav(role),
    );
  }

  // =================== APP BAR ===================

  PreferredSizeWidget _buildAppBar(
    UserRole role,
    dynamic user,
    int unreadCount,
  ) {
    return AppBar(
      title: Text(
        _appBarTitle(role),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _primaryColorForRole(role),
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: _backgroundColorForRole(role),
      iconTheme: IconThemeData(color: _primaryColorForRole(role)),
      actions: [
        // Notification bell with badge
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_rounded,
                color: _primaryColorForRole(role),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Profile icon
        IconButton(
          icon: Icon(Icons.person_rounded, color: _primaryColorForRole(role)),
          onPressed: () {
            _showProfileBottomSheet(
              context,
              user?.name ?? 'User',
              user?.email ?? '',
              role,
            );
          },
        ),
      ],
    );
  }

  // =================== BODY CONTENT ===================

  Widget _buildBody(UserRole role) {
    if (_selectedIndex == 0) {
      switch (role) {
        case UserRole.student:
          return const StudentDashboardPage();
        case UserRole.tutor:
          return const TutorDashboardPage();
        case UserRole.admin:
          return const AdminDashboardPage();
      }
    }

    // Handle other tab indices per role
    return _buildTabContent(role, _selectedIndex);
  }

  Widget _buildTabContent(UserRole role, int index) {
    switch (role) {
      case UserRole.student:
        return _studentTabContent(index);
      case UserRole.tutor:
        return _tutorTabContent(index);
      case UserRole.admin:
        return _adminTabContent(index);
    }
  }

  Widget _studentTabContent(int index) {
    switch (index) {
      case 1:
        return const TutorListPage();
      case 2:
        return const BookingListPage();
      case 3:
        return const ProfilePage();
      default:
        return const StudentDashboardPage();
    }
  }

  Widget _tutorTabContent(int index) {
    switch (index) {
      case 1:
        return const BookingListPage();
      case 2:
        return const ChatListPage();
      case 3:
        return const ProfilePage();
      default:
        return const TutorDashboardPage();
    }
  }

  Widget _adminTabContent(int index) {
    switch (index) {
      case 1:
        return const AdminUsersPage();
      case 2:
        return const AnnouncementsPage();
      case 3:
        return const ProfilePage();
      default:
        return const AdminDashboardPage();
    }
  }

  // =================== BOTTOM NAVIGATION ===================

  Widget _buildBottomNav(UserRole role) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _primaryColorForRole(role),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;
          setState(() => _selectedIndex = index);
        },
        elevation: 0,
        items: _bottomNavItems(role),
      ),
    );
  }

  List<BottomNavigationBarItem> _bottomNavItems(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Tutors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ];
      case UserRole.tutor:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ];
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_rounded),
            label: 'Announce',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ];
    }
  }

  // =================== DRAWER ===================

  Widget _buildDrawer(BuildContext context, dynamic user, UserRole role) {
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColorsForRole(role),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryColorForRole(role),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _roleLabel(role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Role-specific menu items
          ..._drawerItemsForRole(context, role),

          const Divider(),

          // Common items
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red.shade400),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade400)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _drawerItemsForRole(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.student:
        return [
          _drawerItem(Icons.home_rounded, 'Dashboard', () {
            Navigator.pop(context);
            setState(() => _selectedIndex = 0);
          }),
          _drawerItem(Icons.search_rounded, 'Find Tutors', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TutorListPage()));
          }),
          _drawerItem(Icons.calendar_today_rounded, 'My Bookings', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BookingListPage()));
          }),
          _drawerItem(Icons.menu_book_rounded, 'Study Materials', () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudyResourcesPage()),
            );
          }),
          _drawerItem(Icons.chat_rounded, 'Messages', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ChatListPage()));
          }),
          _drawerItem(Icons.account_balance_wallet_rounded, 'Wallet', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WalletPage()));
          }),
          _drawerItem(Icons.notifications_rounded, 'Notifications', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NotificationPage()));
          }),
        ];
      case UserRole.tutor:
        return [
          _drawerItem(Icons.home_rounded, 'Dashboard', () {
            Navigator.pop(context);
            setState(() => _selectedIndex = 0);
          }),
          _drawerItem(Icons.calendar_today_rounded, 'Sessions', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BookingListPage()));
          }),
          _drawerItem(Icons.menu_book_rounded, 'Study Resources', () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudyResourcesPage()),
            );
          }),
          _drawerItem(Icons.chat_rounded, 'Messages', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ChatListPage()));
          }),
          _drawerItem(Icons.trending_up_rounded, 'Earnings', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WalletPage()));
          }),
          _drawerItem(Icons.notifications_rounded, 'Notifications', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NotificationPage()));
          }),
        ];
      case UserRole.admin:
        return [
          _drawerItem(Icons.dashboard_rounded, 'Overview', () {
            Navigator.pop(context);
            setState(() => _selectedIndex = 0);
          }),
          _drawerItem(Icons.people_rounded, 'User Management', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AdminUsersPage()));
          }),
          _drawerItem(Icons.campaign_rounded, 'Announcements', () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
            );
          }),
          _drawerItem(Icons.notifications_rounded, 'Notifications', () {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NotificationPage()));
          }),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'View As',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          _drawerItem(Icons.person_rounded, 'Student View', () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Student View - Admin preview mode'),
              ),
            );
          }),
          _drawerItem(Icons.school_rounded, 'Tutor View', () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tutor View - Admin preview mode')),
            );
          }),
        ];
    }
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: Colors.grey.shade700)),
      onTap: onTap,
    );
  }

  // =================== PROFILE BOTTOM SHEET ===================

  void _showProfileBottomSheet(
    BuildContext context,
    String name,
    String email,
    UserRole role,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundColor: _primaryColorForRole(
                role,
              ).withValues(alpha: 0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _primaryColorForRole(role),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColorForRole(role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _roleLabel(role),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _primaryColorForRole(role),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                Icons.edit_rounded,
                color: _primaryColorForRole(role),
              ),
              title: const Text('View Profile'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings_rounded,
                color: _primaryColorForRole(role),
              ),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings - Coming Soon!')),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // =================== LOGOUT ===================

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, dialogRef, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    Navigator.of(dialogContext).pop();
                    await dialogRef
                        .read(authNotifierProvider.notifier)
                        .logout();
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(role: 'Student'),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =================== ROLE-BASED THEMING ===================

  String _appBarTitle(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student Dashboard';
      case UserRole.tutor:
        return 'Tutor Dashboard';
      case UserRole.admin:
        return 'Admin Panel';
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'STUDENT';
      case UserRole.tutor:
        return 'TUTOR';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  Color _primaryColorForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.blue.shade700;
      case UserRole.tutor:
        return Colors.green.shade700;
      case UserRole.admin:
        return Colors.deepPurple.shade700;
    }
  }

  Color _backgroundColorForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.blue.shade50;
      case UserRole.tutor:
        return Colors.green.shade50;
      case UserRole.admin:
        return Colors.deepPurple.shade50;
    }
  }

  List<Color> _gradientColorsForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return [Colors.blue.shade700, Colors.blue.shade500];
      case UserRole.tutor:
        return [Colors.green.shade700, Colors.teal.shade500];
      case UserRole.admin:
        return [Colors.deepPurple.shade700, Colors.purple.shade500];
    }
  }
}
