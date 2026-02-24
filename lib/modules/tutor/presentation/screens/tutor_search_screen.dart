import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tutor_entity.dart';
import '../../domain/entities/tutor_search_params.dart';
import '../bloc/tutor_bloc.dart';
import '../bloc/tutor_event.dart';
import '../bloc/tutor_state.dart';
import 'tutor_detail_screen.dart';
import '../widgets/tutor_filter_bottom_sheet.dart';
import '../widgets/tutor_list_item.dart';
import '../widgets/tutor_search_bar.dart';

/// Main screen for discovering and searching tutors.
/// Displays searchable and filterable list of tutors with pagination.
class TutorSearchScreen extends StatefulWidget {
  const TutorSearchScreen({super.key});

  @override
  State<TutorSearchScreen> createState() => _TutorSearchScreenState();
}

class _TutorSearchScreenState extends State<TutorSearchScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial tutors
    context.read<TutorBloc>().add(
      const LoadTutorsRequested(searchParams: TutorSearchParams()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when near bottom
      final state = context.read<TutorBloc>().state;
      if (state is TutorLoaded && state.hasNextPage) {
        context.read<TutorBloc>().add(const LoadMoreTutorsRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Tutors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          TutorSearchBar(
            controller: _searchController,
            onSearchChanged: (query) {
              context.read<TutorBloc>().add(SearchQueryChanged(query: query));
            },
            onClear: () {
              _searchController.clear();
              context.read<TutorBloc>().add(
                const SearchQueryChanged(query: ''),
              );
            },
          ),

          // Tutor list
          Expanded(
            child: BlocConsumer<TutorBloc, TutorState>(
              listener: (context, state) {
                if (state is TutorError) {
                  _showErrorSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _buildBody(context, state),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TutorState state) {
    switch (state) {
      case TutorInitial():
      case TutorLoading():
        return const Center(child: CircularProgressIndicator());

      case TutorLoaded():
        return _buildTutorList(context, state);

      case TutorLoadingMore():
        return _buildTutorList(context, state, showLoadingMore: true);

      case TutorError():
        return _buildErrorView(context, state);

      default:
        return const Center(child: Text('Unknown state'));
    }
  }

  Widget _buildTutorList(
    BuildContext context,
    dynamic state, {
    bool showLoadingMore = false,
  }) {
    List<TutorEntity> tutors;

    if (state is TutorLoaded) {
      tutors = state.tutors;
    } else if (state is TutorLoadingMore) {
      tutors = state.currentTutors;
    } else {
      return const Center(child: Text('No tutors available'));
    }

    if (tutors.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: tutors.length + (showLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= tutors.length) {
          // Loading more indicator
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final tutor = tutors[index];
        return TutorListItem(
          tutor: tutor,
          onTap: () => _navigateToTutorDetail(tutor.id),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No tutors found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TutorBloc>().add(const ResetFiltersRequested());
              _searchController.clear();
            },
            child: const Text('Reset Filters'),
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
            'Oops! Something went wrong',
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
          if (state.errorType.canRetry)
            ElevatedButton(
              onPressed: () {
                context.read<TutorBloc>().add(const RefreshTutorsRequested());
              },
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _onRefresh() async {
    context.read<TutorBloc>().add(const RefreshTutorsRequested());

    // Wait for refresh to complete
    await for (final state in context.read<TutorBloc>().stream) {
      if (state is TutorLoaded && !state.isRefreshing) break;
      if (state is TutorError) break;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TutorFilterBottomSheet(
        onApplyFilters: (searchParams) {
          context.read<TutorBloc>().add(
            ApplyFiltersRequested(searchParams: searchParams),
          );
        },
      ),
    );
  }

  void _navigateToTutorDetail(String tutorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorDetailScreen(tutorId: tutorId),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            context.read<TutorBloc>().add(const RefreshTutorsRequested());
          },
        ),
      ),
    );
  }
}
