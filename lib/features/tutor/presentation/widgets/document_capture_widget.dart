import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/camera_providers.dart';
import '../../../../core/widgets/media_preview_page.dart';

class DocumentCaptureWidget extends ConsumerStatefulWidget {
  final String label;
  final Function(File) onFileCaptured;

  const DocumentCaptureWidget({
    super.key,
    required this.label,
    required this.onFileCaptured,
  });

  @override
  ConsumerState<DocumentCaptureWidget> createState() =>
      _DocumentCaptureWidgetState();
}

class _DocumentCaptureWidgetState extends ConsumerState<DocumentCaptureWidget> {
  File? _capturedFile;

  Future<void> _capture() async {
    final cameraService = ref.read(cameraServiceProvider);
    final granted = await cameraService.requestPermissions();

    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Permissions denied')));
      }
      return;
    }

    File? file = await cameraService.pickImageFromCamera();

    if (file != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MediaPreviewPage(
            file: file!,
            onConfirm: () async {
              File finalFile =
                  await cameraService.compressImage(file!) ?? file!;
              setState(() => _capturedFile = finalFile);
              widget.onFileCaptured(finalFile);
              if (mounted) Navigator.of(context).pop();
            },
            onRetake: () {
              Navigator.of(context).pop();
              _capture();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _capture,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: _capturedFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_capturedFile!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to capture document',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
