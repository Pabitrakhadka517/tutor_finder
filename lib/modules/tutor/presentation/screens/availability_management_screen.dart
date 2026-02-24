import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/availability_slot_entity.dart';
import '../bloc/tutor_bloc.dart';
import '../bloc/tutor_event.dart';
import '../bloc/tutor_state.dart';
import '../widgets/availability_slot_editor.dart';

/// Screen for tutors to manage their availability slots.
/// Allows creating, editing, and deleting time slots.
class AvailabilityManagementScreen extends StatefulWidget {
  const AvailabilityManagementScreen({super.key});

  @override
  State<AvailabilityManagementScreen> createState() =>
      _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState
    extends State<AvailabilityManagementScreen> {
  List<AvailabilitySlotEntity> _slots = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Load current availability
    context.read<TutorBloc>().add(const LoadMyAvailabilityRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        actions: [
          if (_hasChanges)
            TextButton(onPressed: _saveChanges, child: const Text('Save')),
        ],
      ),
      body: BlocConsumer<TutorBloc, TutorState>(
        listener: (context, state) {
          if (state is TutorAvailabilityLoaded) {
            setState(() {
              _slots = List.from(state.availabilitySlots);
              _hasChanges = false;
            });
          } else if (state is TutorError) {
            _showErrorSnackBar(context, state.message);
          } else if (state is TutorUpdating &&
              state.operation == 'updating_availability') {
            // Show loading indicator
          } else if (state is TutorAvailabilityLoaded && _hasChanges) {
            // Successfully saved
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Availability updated successfully'),
              ),
            );
            setState(() => _hasChanges = false);
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSlot,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TutorState state) {
    switch (state) {
      case TutorAvailabilityLoading():
        return const Center(child: CircularProgressIndicator());

      case TutorAvailabilityLoaded():
      case TutorUpdating() when state.operation == 'updating_availability':
        return _buildAvailabilityList(
          context,
          isUpdating: state is TutorUpdating,
        );

      case TutorError():
        return _buildErrorView(context, state);

      default:
        return const Center(child: Text('Unknown state'));
    }
  }

  Widget _buildAvailabilityList(
    BuildContext context, {
    bool isUpdating = false,
  }) {
    if (_slots.isEmpty) {
      return _buildEmptyView();
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _slots.length,
            itemBuilder: (context, index) {
              final slot = _slots[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: slot.isBooked
                        ? Colors.red.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    child: Icon(
                      slot.isBooked ? Icons.event_busy : Icons.event_available,
                      color: slot.isBooked ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(slot.timeRange),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slot.dayName),
                      if (slot.note != null)
                        Text(
                          slot.note!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      if (slot.isBooked)
                        const Text(
                          'Booked',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (!slot.isBooked)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editSlot(index, slot);
                          break;
                        case 'delete':
                          _deleteSlot(index);
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),

        if (isUpdating)
          Container(
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No availability slots',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first availability slot to start accepting bookings',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addNewSlot,
            icon: const Icon(Icons.add),
            label: const Text('Add Availability'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, TutorError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load availability',
            style: Theme.of(context).textTheme.titleLarge,
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
                const LoadMyAvailabilityRequested(forceRefresh: true),
              );
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _onRefresh() async {
    context.read<TutorBloc>().add(
      const LoadMyAvailabilityRequested(forceRefresh: true),
    );
  }

  void _addNewSlot() {
    showModalBottomSheet<AvailabilitySlotEntity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AvailabilitySlotEditor(),
    ).then((newSlot) {
      if (newSlot != null) {
        setState(() {
          _slots.add(newSlot);
          _hasChanges = true;
        });
      }
    });
  }

  void _editSlot(int index, AvailabilitySlotEntity slot) {
    showModalBottomSheet<AvailabilitySlotEntity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AvailabilitySlotEditor(existingSlot: slot),
    ).then((editedSlot) {
      if (editedSlot != null) {
        setState(() {
          _slots[index] = editedSlot;
          _hasChanges = true;
        });
      }
    });
  }

  void _deleteSlot(int index) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Availability Slot'),
        content: const Text(
          'Are you sure you want to delete this availability slot?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _slots.removeAt(index);
          _hasChanges = true;
        });
      }
    });
  }

  void _saveChanges() {
    context.read<TutorBloc>().add(UpdateAvailabilityRequested(slots: _slots));
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            context.read<TutorBloc>().add(
              const LoadMyAvailabilityRequested(forceRefresh: true),
            );
          },
        ),
      ),
    );
  }
}
