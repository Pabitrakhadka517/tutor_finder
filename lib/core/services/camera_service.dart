import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Request camera and gallery permissions
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ].request();

    return statuses[Permission.camera]!.isGranted;
  }

  /// Pick an image from Camera
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Pick an image from Gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }

  /// Compress an image before uploading
  Future<File?> compressImage(File file) async {
    final filePath = file.absolute.path;
    final extension = path.extension(filePath);
    final outPath = "${path.withoutExtension(filePath)}_out$extension";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 70,
    );

    if (result == null) return file;
    return File(result.path);
  }

  /// Get a local temporary directory path
  Future<String> getTempPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
}
