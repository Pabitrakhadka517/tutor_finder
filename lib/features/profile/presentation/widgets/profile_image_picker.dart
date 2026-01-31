import 'dart:io';
import 'package:flutter/material.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? profileImageUrl;
  final File? selectedImage;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    this.profileImageUrl,
    this.selectedImage,
    required this.onTap,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  bool _imageLoadError = false;

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
      onTap: widget.onTap,
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
            child: ClipOval(
              child: _buildImageContent(),
            ),
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
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey[400],
      ),
    );
  }
}
