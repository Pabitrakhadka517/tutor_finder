import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/booking_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../review/presentation/pages/create_review_page.dart';
import '../providers/booking_providers.dart';

class BookingListPage extends ConsumerStatefulWidget {
  const BookingListPage({super.key});

  @override
  ConsumerState<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends ConsumerState<BookingListPage> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(bookingListNotifierProvider.notifier).fetchBookings(),
    );
  }

  void _onFilterChanged(String filter) {
    setState(() => _filter = filter);
    ref
        .read(bookingListNotifierProvider.notifier)
        .fetchBookings(status: filter == 'all' ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _filterChip('All', 'all'),
                _filterChip('Pending', 'PENDING'),
                _filterChip('Confirmed', 'CONFIRMED'),
                _filterChip('Paid', 'PAID'),
                _filterChip('Completed', 'COMPLETED'),
                _filterChip('Cancelled', 'CANCELLED'),
              ],
            ),
          ),

          // Booking list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.errorMessage!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(bookingListNotifierProvider.notifier)
                              .refreshBookings(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : state.bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings yet',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(bookingListNotifierProvider.notifier)
                          .refreshBookings();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.bookings.length,
                      itemBuilder: (context, index) =>
                          _BookingCard(booking: state.bookings[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => _onFilterChanged(value),
        selectedColor: Colors.blue.shade100,
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final BookingEntity booking;
  const _BookingCard({required this.booking});

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'PAID':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'REJECTED':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  /// Determine if the current user is the tutor for this booking
  bool _isTutor(WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    final userRole = authState.user?.role.name.toUpperCase() ?? '';
    return userRole == 'TUTOR';
  }

  /// Determine if the current user is the student for this booking
  bool _isStudent(WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    final userRole = authState.user?.role.name.toUpperCase() ?? '';
    return userRole == 'STUDENT';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final isTutor = _isTutor(ref);
    final isStudent = _isStudent(ref);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tutor/student name + status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.tutorName ?? booking.studentName ?? 'Session',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: _statusColor(booking.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Date & Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(dateFormat.format(booking.startTime)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rs.${booking.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                booking.notes!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // === ACTION BUTTONS (role-aware) ===
            _buildActionRow(context, ref, isTutor, isStudent),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    WidgetRef ref,
    bool isTutor,
    bool isStudent,
  ) {
    final List<Widget> actions = [];

    // --- TUTOR actions ---
    if (isTutor) {
      // Accept/Confirm a pending booking
      if (booking.isPending) {
        actions.add(
          _ActionButton(
            label: 'Accept',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            onPressed: () async {
              final confirm = await _confirmAction(
                context,
                'Accept Booking',
                'Are you sure you want to accept this booking?',
              );
              if (!confirm) return;
              final success = await ref
                  .read(bookingActionNotifierProvider.notifier)
                  .updateStatus(booking.id, 'CONFIRMED');
              if (success && context.mounted) {
                _showSnack(context, 'Booking accepted!', Colors.green);
                ref
                    .read(bookingListNotifierProvider.notifier)
                    .refreshBookings();
              }
            },
          ),
        );

        // Reject a pending booking
        actions.add(
          _ActionButton(
            label: 'Reject',
            icon: Icons.cancel_outlined,
            color: Colors.red,
            onPressed: () async {
              final confirm = await _confirmAction(
                context,
                'Reject Booking',
                'Are you sure you want to reject this booking?',
              );
              if (!confirm) return;
              final success = await ref
                  .read(bookingActionNotifierProvider.notifier)
                  .updateStatus(booking.id, 'REJECTED');
              if (success && context.mounted) {
                _showSnack(context, 'Booking rejected', Colors.red);
                ref
                    .read(bookingListNotifierProvider.notifier)
                    .refreshBookings();
              }
            },
          ),
        );
      }

      // Mark Complete for confirmed/paid
      if (booking.isConfirmed || booking.isPaid) {
        actions.add(
          _ActionButton(
            label: 'Complete',
            icon: Icons.done_all,
            color: Colors.green,
            onPressed: () async {
              final success = await ref
                  .read(bookingActionNotifierProvider.notifier)
                  .completeBooking(booking.id);
              if (success && context.mounted) {
                _showSnack(context, 'Booking completed!', Colors.green);
                ref
                    .read(bookingListNotifierProvider.notifier)
                    .refreshBookings();
              }
            },
          ),
        );
      }

      // Cancel for confirmed
      if (booking.isConfirmed) {
        actions.add(
          _ActionButton(
            label: 'Cancel',
            icon: Icons.close,
            color: Colors.red,
            onPressed: () async {
              final confirm = await _confirmAction(
                context,
                'Cancel Booking',
                'Are you sure you want to cancel this booking?',
              );
              if (!confirm) return;
              final success = await ref
                  .read(bookingActionNotifierProvider.notifier)
                  .cancelBooking(booking.id);
              if (success && context.mounted) {
                _showSnack(context, 'Booking cancelled', Colors.red);
                ref
                    .read(bookingListNotifierProvider.notifier)
                    .refreshBookings();
              }
            },
          ),
        );
      }
    }

    // --- STUDENT actions ---
    if (isStudent) {
      // Cancel a pending booking
      if (booking.isPending) {
        actions.add(
          _ActionButton(
            label: 'Cancel',
            icon: Icons.close,
            color: Colors.red,
            onPressed: () async {
              final confirm = await _confirmAction(
                context,
                'Cancel Booking',
                'Are you sure you want to cancel?',
              );
              if (!confirm) return;
              final success = await ref
                  .read(bookingActionNotifierProvider.notifier)
                  .cancelBooking(booking.id);
              if (success && context.mounted) {
                _showSnack(context, 'Booking cancelled', Colors.red);
                ref
                    .read(bookingListNotifierProvider.notifier)
                    .refreshBookings();
              }
            },
          ),
        );
      }

      // Pay for a confirmed booking
      if (booking.isConfirmed) {
        actions.add(
          _ActionButton(
            label: 'Pay Now',
            icon: Icons.payment,
            color: Colors.purple,
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.payment,
                arguments: {
                  'bookingId': booking.id,
                  'tutorName': booking.tutorName ?? 'Tutor',
                  'price': booking.price,
                },
              );
            },
          ),
        );
      }

      // Cancel confirmed/paid
      if (booking.isConfirmed || booking.isPaid) {
        actions.add(
          _ActionButton(
            label: 'Cancel',
            icon: Icons.close,
            color: Colors.red,
            onPressed: () async {
              final confirm = await _confirmAction(
                context,
                'Cancel Booking',
                'Are you sure you want to cancel?',
              );
              if (!confirm) return;
              final success = await ref
                  .read(bookingActionNotifierProvider.notifier)
                  .cancelBooking(booking.id);
              if (success && context.mounted) {
                _showSnack(context, 'Booking cancelled', Colors.red);
                ref
                    .read(bookingListNotifierProvider.notifier)
                    .refreshBookings();
              }
            },
          ),
        );
      }

      // Leave review for completed bookings
      if (booking.isCompleted) {
        actions.add(
          _ActionButton(
            label: 'Review',
            icon: Icons.rate_review,
            color: Colors.amber.shade700,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateReviewPage(
                    bookingId: booking.id,
                    tutorName: booking.tutorName ?? 'Tutor',
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.end,
        children: actions,
      ),
    );
  }

  Future<bool> _confirmAction(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Styled action button for booking cards
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
