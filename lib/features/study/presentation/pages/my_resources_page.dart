import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/study_resource_entity.dart';
import '../providers/study_providers.dart';
import 'upload_resource_page.dart';

class MyResourcesPage extends ConsumerStatefulWidget {
  const MyResourcesPage({super.key});

  @override
  ConsumerState<MyResourcesPage> createState() => _MyResourcesPageState();
}

class _MyResourcesPageState extends ConsumerState<MyResourcesPage> {
  @override
  void initState() {
    super.initState();
    ref.read(studyNotifierProvider.notifier).fetchMyResources();
  }

  Future<void> _deleteResource(StudyResourceEntity resource) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Are you sure you want to delete "${resource.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success =
          await ref.read(studyNotifierProvider.notifier).deleteResource(resource.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyState = ref.watch(studyNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Resources')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const UploadResourcePage()),
          );
          if (result == true) {
            ref.read(studyNotifierProvider.notifier).fetchMyResources();
          }
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
      body: studyState.isLoading && studyState.myResources.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : studyState.error != null && studyState.myResources.isEmpty
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
                            .fetchMyResources(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : studyState.myResources.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No resources uploaded yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the upload button to share study materials',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref
                          .read(studyNotifierProvider.notifier)
                          .fetchMyResources(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: studyState.myResources.length,
                        itemBuilder: (context, index) {
                          final resource = studyState.myResources[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _typeColor(resource.type).withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _typeIcon(resource.type),
                                  color: _typeColor(resource.type),
                                ),
                              ),
                              title: Text(
                                resource.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(resource.category,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Icon(
                                    resource.isPublic
                                        ? Icons.public
                                        : Icons.lock,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    resource.isPublic ? 'Public' : 'Private',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _deleteResource(resource),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'MODULE':
        return Icons.school;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'MODULE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
