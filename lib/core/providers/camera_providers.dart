import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/camera_service.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});
