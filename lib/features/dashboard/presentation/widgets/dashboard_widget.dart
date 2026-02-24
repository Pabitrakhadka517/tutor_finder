import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/dashboard_controller.dart';
import '../models/dashboard_presentation_model.dart';
import '../../domain/value_objects/user_role.dart';
import 'student_dashboard_view.dart';
import 'tutor_dashboard_view.dart';
import 'dashboard_error_widget.dart';
import 'dashboard_loading_widget.dart';

/// Main dashboard widget that displays role-specific content
class DashboardWidget extends StatefulWidget {
  final String userId;
  final UserRole userRole;
  final VoidCallback? onRefresh;

  const DashboardWidget({
    Key? key,
    required this.userId,
    required this.userRole,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().initialize(
        widget.userId,
        widget.userRole,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.getDashboardTitle()),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.refreshDashboard();
                  widget.onRefresh?.call();
                },
                tooltip: 'Refresh Dashboard',
              ),
              if (controller.canAccessAnalytics())
                IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: () => _navigateToAnalytics(context),
                  tooltip: 'View Analytics',
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshDashboard();
              widget.onRefresh?.call();
            },
            child: _buildBody(controller),
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardController controller) {
    if (controller.isLoading) {
      return DashboardLoadingWidget(message: controller.getLoadingMessage());
    }

    if (controller.hasError) {
      return DashboardErrorWidget(
        error: controller.errorMessage ?? 'Unknown error occurred',
        onRetry: () => controller.loadDashboard(),
        onClearError: () => controller.clearError(),
      );
    }

    if (!controller.hasDashboardData()) {
      return _buildEmptyState();
    }

    switch (widget.userRole) {
      case UserRole.student:
        return StudentDashboardView(
          dashboard: controller.studentDashboard!,
          onRefresh: () => controller.refreshDashboard(),
        );
      case UserRole.tutor:
        return TutorDashboardView(
          dashboard: controller.tutorDashboard!,
          onRefresh: () => controller.refreshDashboard(),
        );
      case UserRole.admin:
        return _buildAdminDashboard();
      default:
        return _buildUnsupportedRoleState();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No dashboard data available',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start using the platform to see your statistics',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<DashboardController>().loadDashboard(
              forceRefresh: true,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedRoleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.orange[400]),
          const SizedBox(height: 16),
          Text(
            'Unsupported User Role',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.orange[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Dashboard not available for this user role',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.orange[500]),
          ),
        ],
      ),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    // Navigate to analytics page
    Navigator.of(context).pushNamed('/dashboard/analytics');
  }
}
