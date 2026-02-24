import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../booking/presentation/pages/create_booking_page.dart';
import '../../../review/presentation/pages/tutor_reviews_page.dart';
import '../providers/tutor_providers.dart';

class TutorDetailPage extends ConsumerStatefulWidget {
  final String tutorId;

  const TutorDetailPage({super.key, required this.tutorId});

  @override
  ConsumerState<TutorDetailPage> createState() => _TutorDetailPageState();
}

class _TutorDetailPageState extends ConsumerState<TutorDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(tutorDetailNotifierProvider.notifier)
          .fetchTutor(widget.tutorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorDetailNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(tutorDetailNotifierProvider.notifier)
                        .fetchTutor(widget.tutorId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : state.tutor == null
          ? const Center(child: Text('Tutor not found'))
          : _buildTutorDetail(context),
    );
  }

  Widget _buildTutorDetail(BuildContext context) {
    final tutor = ref.read(tutorDetailNotifierProvider).tutor!;

    return CustomScrollView(
      slivers: [
        // Sliver AppBar with tutor image
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: Colors.blue.shade700,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              tutor.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: tutor.profileImage != null
                      ? NetworkImage(tutor.profileImage!)
                      : null,
                  child: tutor.profileImage == null
                      ? Text(
                          tutor.fullName.isNotEmpty
                              ? tutor.fullName[0].toUpperCase()
                              : 'T',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verification badge
                if (tutor.verificationStatus == 'VERIFIED')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Verified Tutor',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      Icons.star,
                      Colors.amber,
                      tutor.averageRating.toStringAsFixed(1),
                      '${tutor.totalReviews} reviews',
                    ),
                    _buildStatChip(
                      Icons.school,
                      Colors.blue,
                      '${tutor.experienceYears}',
                      'Years exp.',
                    ),
                    _buildStatChip(
                      Icons.people,
                      Colors.purple,
                      '${tutor.totalClasses}',
                      'Classes',
                    ),
                    _buildStatChip(
                      Icons.attach_money,
                      Colors.green,
                      'Rs.${tutor.hourlyRate.toStringAsFixed(0)}',
                      'per hour',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Bio
                if (tutor.bio != null && tutor.bio!.isNotEmpty) ...[
                  _sectionTitle('About'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tutor.bio!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Subjects
                if (tutor.subjects.isNotEmpty) ...[
                  _sectionTitle('Subjects'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tutor.subjects
                        .map(
                          (s) => Chip(
                            label: Text(s),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Languages
                if (tutor.languages.isNotEmpty) ...[
                  _sectionTitle('Languages'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tutor.languages
                        .map(
                          (l) => Chip(
                            label: Text(l),
                            backgroundColor: Colors.green.shade50,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Contact Info
                _sectionTitle('Contact'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _infoRow(Icons.email, tutor.email),
                      if (tutor.phone != null && tutor.phone!.isNotEmpty) ...[
                        const Divider(height: 16),
                        _infoRow(Icons.phone, tutor.phone!),
                      ],
                      if (tutor.address != null &&
                          tutor.address!.isNotEmpty) ...[
                        const Divider(height: 16),
                        _infoRow(Icons.location_on, tutor.address!),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // View Reviews button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              TutorReviewsPage(tutorId: tutor.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review),
                    label: Text('View Reviews (${tutor.totalReviews})'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Book Now button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateBookingPage(tutor: tutor),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book a Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade900,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
