import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/study_providers.dart';

class UploadResourcePage extends ConsumerStatefulWidget {
  const UploadResourcePage({super.key});

  @override
  ConsumerState<UploadResourcePage> createState() => _UploadResourcePageState();
}

class _UploadResourcePageState extends ConsumerState<UploadResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedType = 'PDF';
  bool _isPublic = true;
  String? _selectedFilePath;
  String? _selectedFileName;

  final _types = ['PDF', 'MODULE', 'OTHER'];

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'zip'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(studyNotifierProvider.notifier)
        .uploadResource(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          type: _selectedType,
          filePath: _selectedFilePath!,
          isPublic: _isPublic,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resource uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final error = ref.read(studyNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyState = ref.watch(studyNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resource')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter resource title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Mathematics, Science, English',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Category is required' : null,
            ),
            const SizedBox(height: 16),

            // Type dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Resource Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.type_specimen),
              ),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            const SizedBox(height: 16),

            // Public toggle
            SwitchListTile(
              title: const Text('Public Resource'),
              subtitle: const Text('Visible to all students'),
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 24),

            // File picker
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFilePath != null
                        ? Colors.green
                        : Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedFilePath != null
                      ? Colors.green[50]
                      : Colors.grey[50],
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFilePath != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _selectedFilePath != null
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFileName ?? 'Tap to select a file',
                      style: TextStyle(
                        color: _selectedFilePath != null
                            ? Colors.green[700]
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_selectedFilePath == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'PDF, DOC, PPT, TXT, ZIP',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Upload button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: studyState.isLoading ? null : _upload,
                icon: studyState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(
                  studyState.isLoading ? 'Uploading...' : 'Upload Resource',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
