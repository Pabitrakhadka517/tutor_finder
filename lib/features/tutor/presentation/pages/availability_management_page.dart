import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/availability_slot_entity.dart';
import '../../data/models/availability_slot_model.dart';
import '../providers/tutor_providers.dart';

/// Riverpod-based availability management page for tutors
/// Allows creating and viewing time slots (DateTime-based)
class AvailabilityManagementPage extends ConsumerStatefulWidget {
  const AvailabilityManagementPage({super.key});

  @override
  ConsumerState<AvailabilityManagementPage> createState() =>
      _AvailabilityManagementPageState();
}

class _AvailabilityManagementPageState
    extends ConsumerState<AvailabilityManagementPage> {
  List<AvailabilitySlotEntity> _slots = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // For new slot creation
  DateTime? _newStartDate;
  TimeOfDay? _newStartTime;
  TimeOfDay? _newEndTime;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(tutorRepositoryProvider);
    final result = await repo.getMyAvailability();

    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _error = failure.message;
      }),
      (slots) => setState(() {
        _isLoading = false;
        _slots = List.from(slots);
      }),
    );
  }

  Future<void> _addNewSlot() async {
    // Pick date
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    // Pick start time
    final startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select start time',
    );
    if (startTime == null || !mounted) return;

    // Pick end time
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTime.hour + 1,
        minute: startTime.minute,
      ),
      helpText: 'Select end time',
    );
    if (endTime == null || !mounted) return;

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Save to backend
    setState(() => _isSaving = true);
    final repo = ref.read(tutorRepositoryProvider);
    final newSlots = [
      ..._slots.map(
        (s) => AvailabilitySlotModel(
          id: s.id,
          tutorId: s.tutorId,
          startTime: s.startTime,
          endTime: s.endTime,
          isBooked: s.isBooked,
        ),
      ),
      AvailabilitySlotModel(
        id: '',
        tutorId: '',
        startTime: startDateTime,
        endTime: endDateTime,
      ),
    ];

    final result = await repo.setAvailability(newSlots);
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Slot added!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAvailability(); // Refresh list
        }
      },
    );
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadAvailability,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _slots.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No availability slots yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your available times',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAvailability,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  final isPast = slot.endTime.isBefore(DateTime.now());
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: slot.isBooked
                        ? Colors.orange.shade50
                        : isPast
                        ? Colors.grey.shade100
                        : Colors.green.shade50,
                    child: ListTile(
                      leading: Icon(
                        slot.isBooked
                            ? Icons.event_busy
                            : isPast
                            ? Icons.history
                            : Icons.event_available,
                        color: slot.isBooked
                            ? Colors.orange
                            : isPast
                            ? Colors.grey
                            : Colors.green,
                      ),
                      title: Text(
                        dateFormat.format(slot.startTime),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${timeFormat.format(slot.startTime)} - ${timeFormat.format(slot.endTime)}',
                      ),
                      trailing: slot.isBooked
                          ? Chip(
                              label: const Text(
                                'Booked',
                                style: TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.orange.shade100,
                            )
                          : isPast
                          ? const Text(
                              'Past',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          : const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: _isSaving
          ? const FloatingActionButton(
              onPressed: null,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : FloatingActionButton(
              onPressed: _addNewSlot,
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
