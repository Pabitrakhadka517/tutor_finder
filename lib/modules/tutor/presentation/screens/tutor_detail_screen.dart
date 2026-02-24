import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tutor_entity.dart';
import '../bloc/tutor_bloc.dart';
import '../bloc/tutor_event.dart';
import '../bloc/tutor_state.dart';
import '../widgets/tutor_detail_info.dart';
import '../widgets/tutor_availability_view.dart';

/// Screen displaying detailed information about a specific tutor.
/// Shows comprehensive tutor data including availability and reviews.
class TutorDetailScreen extends StatefulWidget {
  const TutorDetailScreen({super.key, required this.tutorId});

  final String tutorId;

  @override
  State<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends State<TutorDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load tutor detail
    context.read<TutorBloc>().add(
      LoadTutorDetailRequested(tutorId: widget.tutorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TutorBloc, TutorState>(
        listener: (context, state) {
          if (state is TutorError) {
            _showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TutorState state) {
    switch (state) {
      case TutorDetailLoading():
        return _buildLoadingScaffold();

      case TutorDetailLoaded():
        return _buildTutorDetail(context, state.tutor);

      case TutorError() when state.previousState is TutorDetailLoaded:
        // Show previous data with error handling
        final previousState = state.previousState as TutorDetailLoaded;
        return _buildTutorDetail(context, previousState.tutor);

      case TutorError():
        return _buildErrorScaffold(context, state);

      default:
        return _buildLoadingScaffold();
    }
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor Details')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTutorDetail(BuildContext context, TutorEntity tutor) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with tutor image and basic info
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tutor.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image or color
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                      ),
                    ),
                  ),

                  // Tutor profile image
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundImage: tutor.profileImage != null
                            ? NetworkImage(tutor.profileImage!)
                            : null,
                        child: tutor.profileImage == null
                            ? Text(
                                tutor.fullName.isNotEmpty
                                    ? tutor.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 24),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => _toggleFavorite(tutor),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareProfile(tutor),
              ),
            ],
          ),

          // Tutor information
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TutorDetailInfo(tutor: tutor),
            ),
          ),

          // Availability section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TutorAvailabilityView(tutorId: tutor.id),
            ),
          ),
        ],
      ),

      // Book lesson button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.priceDisplay,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'per hour',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Book button
              Expanded(
                child: ElevatedButton(
                  onPressed: tutor.isAvailable
                      ? () => _bookLesson(tutor)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    tutor.isAvailable ? 'Book Lesson' : 'Not Available',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, TutorError state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor Details')),
      body: Center(
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
              'Failed to load tutor details',
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
                  LoadTutorDetailRequested(
                    tutorId: widget.tutorId,
                    forceRefresh: true,
                  ),
                );
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  void _toggleFavorite(TutorEntity tutor) {
    // TODO: Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tutor.fullName} added to favorites')),
    );
  }

  void _shareProfile(TutorEntity tutor) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share feature coming soon')));
  }

  void _bookLesson(TutorEntity tutor) {
    // TODO: Navigate to booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking lesson with ${tutor.fullName}...')),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            context.read<TutorBloc>().add(
              LoadTutorDetailRequested(
                tutorId: widget.tutorId,
                forceRefresh: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
