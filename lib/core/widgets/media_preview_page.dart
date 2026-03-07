import 'dart:io';
import 'package:flutter/material.dart';

class MediaPreviewPage extends StatelessWidget {
  final File file;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;

  const MediaPreviewPage({
    super.key,
    required this.file,
    required this.onConfirm,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Preview Photo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(child: Image.file(file)),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onRetake,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Retake'),
                ),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Confirm & Upload'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
