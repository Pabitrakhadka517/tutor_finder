import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/study_resource_entity.dart';
import '../providers/study_providers.dart';

class StudyResourcesPage extends ConsumerStatefulWidget {
  const StudyResourcesPage({super.key});

  @override
  ConsumerState<StudyResourcesPage> createState() =>
      _StudyResourcesPageState();
}

class _StudyResourcesPageState extends ConsumerState<StudyResourcesPage> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    ref.read(studyNotifierProvider.notifier).fetchResources();
  }

  @override
  Widget build(BuildContext context) {
    final studyState = ref.watch(studyNotifierProvider);

    // Extract unique categories
    final categories =
        studyState.resources.map((r) => r.category).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Resources')),
      body: Column(
        children: [
          // Category filter chips
          if (categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                        ref
                            .read(studyNotifierProvider.notifier)
                            .fetchResources();
                      },
                    ),
                  ),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          ref
                              .read(studyNotifierProvider.notifier)
                              .fetchResources(category: cat);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Resources list
          Expanded(
            child: studyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : studyState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              studyState.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(studyNotifierProvider.notifier)
                                  .fetchResources(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : studyState.resources.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.library_books,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No resources available',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => ref
                                .read(studyNotifierProvider.notifier)
                                .fetchResources(category: _selectedCategory),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: studyState.resources.length,
                              itemBuilder: (context, index) {
                                return _ResourceCard(
                                  resource: studyState.resources[index],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final StudyResourceEntity resource;

  const _ResourceCard({required this.resource});

  IconData _typeIcon() {
    switch (resource.type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'MODULE':
        return Icons.school;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _typeColor() {
    switch (resource.type) {
      case 'PDF':
        return Colors.red;
      case 'MODULE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _typeColor().withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_typeIcon(), color: _typeColor()),
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    resource.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  resource.type,
                  style: TextStyle(
                    fontSize: 11,
                    color: _typeColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (resource.size != null || resource.duration != null) ...[
              const SizedBox(height: 4),
              Text(
                [
                  if (resource.size != null) resource.size!,
                  if (resource.duration != null) resource.duration!,
                ].join(' • '),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
            if (resource.tutorName != null) ...[
              const SizedBox(height: 2),
              Text(
                'By ${resource.tutorName}',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.download, color: Colors.blue),
        onTap: () {
          // Open resource URL
          final url = ApiEndpoints.getImageUrl(resource.url);
          if (url != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening: ${resource.title}')),
            );
          }
        },
      ),
    );
  }
}
