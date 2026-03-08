import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../tutor/domain/entities/tutor_entity.dart';
import '../../../tutor/domain/entities/availability_slot_entity.dart';
import '../../../tutor/presentation/providers/tutor_providers.dart';
import '../providers/booking_providers.dart';

class CreateBookingPage extends ConsumerStatefulWidget {
  final TutorEntity tutor;

  const CreateBookingPage({super.key, required this.tutor});

  @override
  ConsumerState<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends ConsumerState<CreateBookingPage> {
  List<AvailabilitySlotEntity> _allSlots = [];
  List<AvailabilitySlotEntity> _filteredSlots = [];
  AvailabilitySlotEntity? _selectedSlot;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoadingSlots = true;
  String? _slotsError;
  final _notesController = TextEditingController();

  double get _estimatedPrice {
    if (_selectedSlot == null) return 0;
    final durationMinutes = _selectedSlot!.endTime
        .difference(_selectedSlot!.startTime)
        .inMinutes;
    final durationHours = durationMinutes / 60.0;
    if (durationHours <= 0) return 0;
    return widget.tutor.hourlyRate * durationHours;
  }

  String get _durationText {
    if (_selectedSlot == null) return '';
    final durationMinutes = _selectedSlot!.endTime
        .difference(_selectedSlot!.startTime)
        .inMinutes;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool _isSameSlot(AvailabilitySlotEntity a, AvailabilitySlotEntity b) {
    if (a.id.isNotEmpty && b.id.isNotEmpty) {
      return a.id == b.id;
    }
    return a.startTime == b.startTime && a.endTime == b.endTime;
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoadingSlots = true;
      _slotsError = null;
    });

    final repo = ref.read(tutorRepositoryProvider);
    final result = await repo.getTutorAvailability(widget.tutor.id);

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoadingSlots = false;
        _slotsError = failure.message;
      }),
      (slots) {
        // Filter out past slots and already-booked slots
        final now = DateTime.now();
        final availableSlots =
            slots.where((s) => !s.isBooked && s.startTime.isAfter(now)).toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

        DateTime selectedDate = _selectedDate;
        if (availableSlots.isNotEmpty) {
          final availableDates =
              availableSlots
                  .map(
                    (slot) => DateTime(
                      slot.startTime.year,
                      slot.startTime.month,
                      slot.startTime.day,
                    ),
                  )
                  .toSet()
                  .toList()
                ..sort();

          final hasCurrentDate = availableDates.any(
            (date) =>
                date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day,
          );

          if (!hasCurrentDate) {
            selectedDate = availableDates.first;
          }
        }

        setState(() {
          _isLoadingSlots = false;
          _allSlots = availableSlots;
          _selectedDate = selectedDate;
          _filterSlotsByDate();
        });
      },
    );
  }

  void _filterSlotsByDate() {
    _filteredSlots = _allSlots.where((slot) {
      final local = slot.startTime.toLocal();
      return local.year == _selectedDate.year &&
          local.month == _selectedDate.month &&
          local.day == _selectedDate.day;
    }).toList();
    _selectedSlot = null;
  }

  /// Get unique dates that have available slots
  List<DateTime> get _availableDates {
    final dates = <DateTime>{};
    for (final slot in _allSlots) {
      final local = slot.startTime.toLocal();
      dates.add(DateTime(local.year, local.month, local.day));
    }
    final sorted = dates.toList()..sort();
    return sorted;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _filterSlotsByDate();
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(bookingActionNotifierProvider.notifier)
        .createBooking(
          tutorId: widget.tutor.id,
          startTime: _selectedSlot!.startTime,
          endTime: _selectedSlot!.endTime,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final state = ref.read(bookingActionNotifierProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Failed to create booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(bookingActionNotifierProvider);
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Session'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutor card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade200,
                    child:
                        widget.tutor.profileImage != null &&
                            widget.tutor.profileImage!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              widget.tutor.profileImage!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                widget.tutor.fullName.isNotEmpty
                                    ? widget.tutor.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            widget.tutor.fullName.isNotEmpty
                                ? widget.tutor.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tutor.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Colors.green.shade700,
                            ),
                            Text(
                              'Rs.${widget.tutor.hourlyRate.toStringAsFixed(0)}/hour',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Available Dates Section
            _sectionLabel('Select Date'),
            const SizedBox(height: 8),

            // Date picker button
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Quick date chips for dates that have slots
            if (_availableDates.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableDates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final date = _availableDates[index];
                    final isSelected =
                        date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;
                    return ChoiceChip(
                      label: Text(DateFormat('MMM d').format(date)),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade100,
                      onSelected: (_) {
                        setState(() {
                          _selectedDate = date;
                          _filterSlotsByDate();
                        });
                      },
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Available Time Slots Section
            _sectionLabel('Available Time Slots'),
            const SizedBox(height: 8),

            if (_isLoadingSlots)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_slotsError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400),
                    const SizedBox(height: 8),
                    Text(
                      _slotsError!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadAvailability,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_allSlots.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 40,
                      color: Colors.orange.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No available time slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This tutor has not set any availability yet.\nPlease message the tutor to arrange a session.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (_filteredSlots.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No slots on this date',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try selecting a different date above.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Show available slot cards
              ...List.generate(_filteredSlots.length, (index) {
                final slot = _filteredSlots[index];
                final isSelected =
                    _selectedSlot != null && _isSameSlot(_selectedSlot!, slot);
                final durationMin = slot.endTime
                    .difference(slot.startTime)
                    .inMinutes;
                final hours = durationMin ~/ 60;
                final mins = durationMin % 60;
                final durationStr = hours > 0 && mins > 0
                    ? '${hours}h ${mins}m'
                    : hours > 0
                    ? '${hours}h'
                    : '${mins}m';
                final slotPrice =
                    widget.tutor.hourlyRate * (durationMin / 60.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSlot = slot),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Radio indicator
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          // Time info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${timeFormat.format(slot.startTime.toLocal())} - ${timeFormat.format(slot.endTime.toLocal())}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.blue.shade700
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Duration: $durationStr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Price tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rs.${slotPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Notes
            _sectionLabel('Notes (Optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any specific topics or requests...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Price summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedSlot != null
                    ? Colors.green.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedSlot != null
                      ? Colors.green.shade200
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hourly Rate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Rs.${widget.tutor.hourlyRate.toStringAsFixed(0)}/hr',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedSlot != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _durationText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _selectedSlot != null
                            ? 'Rs.${_estimatedPrice.toStringAsFixed(0)}'
                            : 'Select a slot',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _selectedSlot != null
                              ? Colors.green.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: actionState.isLoading || _selectedSlot == null
                    ? null
                    : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: actionState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Booking Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }
}
