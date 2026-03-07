import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/camera_providers.dart';
import '../../../../core/widgets/media_preview_page.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  final String? profileImageUrl;
  final File? selectedImage;
  final Function(File) onImageSelected;

  const ProfileImagePicker({
    super.key,
    this.profileImageUrl,
    this.selectedImage,
    required this.onImageSelected,
  });

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  bool _imageLoadError = false;

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(fromCamera: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(fromCamera: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final cameraService = ref.read(cameraServiceProvider);

    final granted = await cameraService.requestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
      return;
    }

    File? image;
    if (fromCamera) {
      image = await cameraService.pickImageFromCamera();
    } else {
      image = await cameraService.pickImageFromGallery();
    }

    if (image != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MediaPreviewPage(
            file: image!,
            onConfirm: () async {
              final compressed = await cameraService.compressImage(image!);
              widget.onImageSelected(compressed ?? image!);
              if (mounted) Navigator.of(context).pop();
            },
            onRetake: () {
              Navigator.of(context).pop();
              _pickImage(fromCamera: fromCamera);
            },
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(ProfileImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset error if image URL changes
    if (widget.profileImageUrl != oldWidget.profileImageUrl) {
      _imageLoadError = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: _buildImageContent()),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    // Show selected image first
    if (widget.selectedImage != null) {
      return Image.file(
        widget.selectedImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // Show network image if available and no error
    if (widget.profileImageUrl != null &&
        widget.profileImageUrl!.isNotEmpty &&
        !_imageLoadError) {
      return Image.network(
        widget.profileImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_imageLoadError) {
              setState(() {
                _imageLoadError = true;
              });
            }
          });
          return _buildPlaceholder();
        },
      );
    }

    // Show placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
    );
  }
}
