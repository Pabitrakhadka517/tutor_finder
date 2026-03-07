import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import '../../../chat/presentation/pages/chat_room_page.dart';
import '../../../chat/presentation/providers/chat_providers.dart';

/// Page showing all unique students a tutor has worked with
/// Derived from booking data (completed/confirmed/paid bookings)
class TutorStudentsPage extends ConsumerStatefulWidget {
  const TutorStudentsPage({super.key});

  @override
  ConsumerState<TutorStudentsPage> createState() => _TutorStudentsPageState();
}

class _TutorStudentsPageState extends ConsumerState<TutorStudentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(bookingListNotifierProvider.notifier).fetchBookings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingListNotifierProvider);

    // Extract unique students from bookings
    final studentMap = <String, _StudentInfo>{};
    for (final booking in state.bookings) {
      if (booking.studentId.isNotEmpty) {
        final existing = studentMap[booking.studentId];
        final sessionsCount = (existing?.totalSessions ?? 0) + 1;
        studentMap[booking.studentId] = _StudentInfo(
          id: booking.studentId,
          name: booking.studentName ?? 'Student',
          image: booking.studentImage,
          totalSessions: sessionsCount,
          lastSession:
              existing == null ||
                  booking.startTime.isAfter(existing.lastSession)
              ? booking.startTime
              : existing.lastSession,
        );
      }
    }
    final students = studentMap.values.toList()
      ..sort((a, b) => b.lastSession.compareTo(a.lastSession));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
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
          : students.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Students will appear here after bookings',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref
                  .read(bookingListNotifierProvider.notifier)
                  .refreshBookings(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _StudentCard(
                    student: student,
                    onMessage: () =>
                        _startChat(context, ref, student.id, student.name),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _startChat(
    BuildContext context,
    WidgetRef ref,
    String studentId,
    String studentName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatId = await ref
          .read(chatListNotifierProvider.notifier)
          .createChat(studentId);
      if (context.mounted) {
        Navigator.of(context).pop();
        if (chatId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ChatRoomPage(chatId: chatId, recipientName: studentName),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not start chat')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _StudentInfo {
  final String id;
  final String name;
  final String? image;
  final int totalSessions;
  final DateTime lastSession;

  const _StudentInfo({
    required this.id,
    required this.name,
    this.image,
    required this.totalSessions,
    required this.lastSession,
  });
}

class _StudentCard extends StatelessWidget {
  final _StudentInfo student;
  final VoidCallback onMessage;

  const _StudentCard({required this.student, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: student.image != null
              ? NetworkImage(student.image!)
              : null,
          child: student.image == null
              ? Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${student.totalSessions} session${student.totalSessions == 1 ? '' : 's'}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        trailing: IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: Colors.blue.shade700),
          onPressed: onMessage,
          tooltip: 'Message',
        ),
      ),
    );
  }
}
