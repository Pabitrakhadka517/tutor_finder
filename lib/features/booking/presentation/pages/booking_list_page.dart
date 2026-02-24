import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/booking_entity.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

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
                    color: _statusColor(booking.status).withOpacity(0.15),
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

            // Actions
            if (booking.isPending || booking.isConfirmed || booking.isPaid)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (booking.isPending)
                      TextButton(
                        onPressed: () async {
                          final success = await ref
                              .read(bookingActionNotifierProvider.notifier)
                              .cancelBooking(booking.id);
                          if (success && context.mounted) {
                            ref
                                .read(bookingListNotifierProvider.notifier)
                                .refreshBookings();
                          }
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (booking.isConfirmed || booking.isPaid)
                      TextButton(
                        onPressed: () async {
                          final success = await ref
                              .read(bookingActionNotifierProvider.notifier)
                              .completeBooking(booking.id);
                          if (success && context.mounted) {
                            ref
                                .read(bookingListNotifierProvider.notifier)
                                .refreshBookings();
                          }
                        },
                        child: const Text('Mark Complete'),
                      ),
                    if (booking.isConfirmed || booking.isPaid)
                      TextButton(
                        onPressed: () async {
                          final success = await ref
                              .read(bookingActionNotifierProvider.notifier)
                              .cancelBooking(booking.id);
                          if (success && context.mounted) {
                            ref
                                .read(bookingListNotifierProvider.notifier)
                                .refreshBookings();
                          }
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
