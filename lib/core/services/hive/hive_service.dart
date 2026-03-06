import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider for the HiveService
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

/// Service class for managing Hive local database operations
class HiveService {
  /// Get an already open box
  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// Open a box if not already open
  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return Hive.openBox<T>(boxName);
  }

  /// Put a value in a box
  Future<void> put<T>(String boxName, dynamic key, T value) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  /// Get a value from a box
  Future<T?> get<T>(String boxName, dynamic key) async {
    final box = await openBox<T>(boxName);
    return box.get(key);
  }

  /// Get all values from a box
  Future<List<T>> getAll<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    return box.values.toList();
  }

  /// Delete a value from a box
  Future<void> delete<T>(String boxName, dynamic key) async {
    final box = await openBox<T>(boxName);
    await box.delete(key);
  }

  /// Clear all data from a box
  Future<void> clearBox<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    await box.clear();
  }

  /// Check if a key exists in a box
  Future<bool> containsKey<T>(String boxName, dynamic key) async {
    final box = await openBox<T>(boxName);
    return box.containsKey(key);
  }

  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// Close all boxes
  Future<void> closeAll() async {
    await Hive.close();
  }
}
