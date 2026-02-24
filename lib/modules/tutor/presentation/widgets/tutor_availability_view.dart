import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/availability_slot_entity.dart';
import '../bloc/tutor_bloc.dart';
import '../bloc/tutor_event.dart';
import '../bloc/tutor_state.dart';

/// Widget displaying tutor's availability slots in a calendar-like format.
/// Used in tutor detail screen to show available booking times.
class TutorAvailabilityView extends StatefulWidget {
  const TutorAvailabilityView({super.key, required this.tutorId});

  final String tutorId;

  @override
  State<TutorAvailabilityView> createState() => _TutorAvailabilityViewState();
}

class _TutorAvailabilityViewState extends State<TutorAvailabilityView> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load availability for this tutor
    context.read<TutorBloc>().add(
      LoadTutorAvailabilityRequested(
        tutorId: widget.tutorId,
        date: _selectedDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Date selector
        _buildDateSelector(),
        const SizedBox(height: 16),

        // Availability slots
        BlocConsumer<TutorBloc, TutorState>(
          listener: (context, state) {
            if (state is TutorError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return _buildAvailabilitySection(context, state);
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: _previousDay,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: _selectDate,
                  child: Text(
                    _formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _nextDay,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection(BuildContext context, TutorState state) {
    switch (state) {
      case TutorAvailabilityLoading():
        return _buildLoadingView();

      case TutorAvailabilityLoaded():
        return _buildAvailabilitySlots(context, state.availabilitySlots);

      case TutorError():
        return _buildErrorView(context, state);

      default:
        return _buildEmptyView();
    }
  }

  Widget _buildLoadingView() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildAvailabilitySlots(
    BuildContext context,
    List<AvailabilitySlotEntity> slots,
  ) {
    if (slots.isEmpty) {
      return _buildNoSlotsView();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available time slots',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...slots.map((slot) => _buildSlotItem(context, slot)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotItem(BuildContext context, AvailabilitySlotEntity slot) {
    final isBooked = slot.isBooked;
    final isPast = slot.startTime.isBefore(DateTime.now());
    final isAvailable = !isBooked && !isPast;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isAvailable ? () => _bookSlot(slot) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAvailable
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            color: isAvailable
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Icon(
                isBooked ? Icons.event_busy : Icons.event_available,
                color: isBooked
                    ? Colors.red
                    : isPast
                    ? Colors.grey
                    : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.timeRange,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? null
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    if (slot.note != null)
                      Text(
                        slot.note!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              if (isBooked)
                const Chip(
                  label: Text('Booked', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                )
              else if (isPast)
                const Chip(
                  label: Text('Past', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.grey,
                  labelStyle: TextStyle(color: Colors.white),
                )
              else
                const Chip(
                  label: Text('Available', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSlotsView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No availability',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This tutor has no available slots for the selected date.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, TutorError state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load availability',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<TutorBloc>().add(
                    LoadTutorAvailabilityRequested(
                      tutorId: widget.tutorId,
                      date: _selectedDate,
                      forceRefresh: true,
                    ),
                  );
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.schedule,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading availability...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadAvailability();
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadAvailability();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailability();
    }
  }

  void _loadAvailability() {
    context.read<TutorBloc>().add(
      LoadTutorAvailabilityRequested(
        tutorId: widget.tutorId,
        date: _selectedDate,
        forceRefresh: true,
      ),
    );
  }

  void _bookSlot(AvailabilitySlotEntity slot) {
    // TODO: Navigate to booking screen or show booking modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Lesson'),
        content: Text('Book a lesson for ${slot.timeRange}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement booking logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking ${slot.timeRange}...')),
              );
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    } else if (date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year) {
      return 'Tomorrow';
    } else {
      return '${_getWeekdayName(date.weekday)}, ${_getMonthName(date.month)} ${date.day}';
    }
  }

  String _getWeekdayName(int weekday) {
    return switch (weekday) {
      1 => 'Monday',
      2 => 'Tuesday',
      3 => 'Wednesday',
      4 => 'Thursday',
      5 => 'Friday',
      6 => 'Saturday',
      7 => 'Sunday',
      _ => 'Unknown',
    };
  }

  String _getMonthName(int month) {
    return switch (month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      12 => 'Dec',
      _ => 'Unknown',
    };
  }
}
