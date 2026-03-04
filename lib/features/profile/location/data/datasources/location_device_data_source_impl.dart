import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../domain/entities/location_entity.dart';
import '../../domain/entities/location_permission_status.dart';
import '../../domain/location_failures.dart';
import '../datasources/location_device_data_source.dart';

/// Implementation of LocationDeviceDataSource using:
/// - geolocator for GPS coordinates
/// - geocoding for reverse geocoding
/// - permission_handler for permission management
class LocationDeviceDataSourceImpl implements LocationDeviceDataSource {
  /// Convert permission_handler status to our domain status
  LocationPermissionStatus _mapPermissionStatus(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.denied:
        return LocationPermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return LocationPermissionStatus.deniedForever;
      case ph.PermissionStatus.granted:
        return LocationPermissionStatus.granted;
      case ph.PermissionStatus.restricted:
        return LocationPermissionStatus.restricted;
      case ph.PermissionStatus.limited:
        return LocationPermissionStatus.granted; // Treat limited as granted
      case ph.PermissionStatus.provisional:
        return LocationPermissionStatus.granted;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    // First check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final status = await ph.Permission.location.status;
    return _mapPermissionStatus(status);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    // First check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Request permission
    final status = await ph.Permission.location.request();

    // If denied on iOS, it might be "denied forever" scenario
    if (status.isDenied) {
      // Check if we can request again
      final canRequest =
          await ph.Permission.location.shouldShowRequestRationale;
      if (!canRequest && Platform.isAndroid) {
        // On Android, if shouldShowRequestRationale is false after denial,
        // it means permanently denied
        return LocationPermissionStatus.deniedForever;
      }
    }

    return _mapPermissionStatus(status);
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  @override
  Future<bool> openAppSettings() async {
    return ph.openAppSettings();
  }

  @override
  Future<({double latitude, double longitude})> getCurrentCoordinates({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // Get position with timeout
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: timeout,
            ),
          ).timeout(
            timeout,
            onTimeout: () {
              throw const LocationTimeoutFailure();
            },
          );

      // Debug logging - remove in production
      print(
        '📍 GPS Coordinates: lat=${position.latitude}, lng=${position.longitude}',
      );
      print(
        '📍 Accuracy: ${position.accuracy}m, Timestamp: ${position.timestamp}',
      );

      return (latitude: position.latitude, longitude: position.longitude);
    } on TimeoutException {
      throw const LocationTimeoutFailure();
    } on LocationServiceDisabledException {
      throw const LocationServiceDisabledFailure();
    } catch (e) {
      if (e is LocationTimeoutFailure || e is LocationServiceDisabledFailure) {
        rethrow;
      }
      throw LocationGeneralFailure('Failed to get GPS coordinates: $e');
    }
  }

  @override
  Future<LocationEntity> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('📍 Reverse geocoding: lat=$latitude, lng=$longitude');

      final placemarks = await placemarkFromCoordinates(latitude, longitude)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw const LocationNetworkFailure(
                'Address lookup timed out. Check your internet connection.',
              );
            },
          );

      if (placemarks.isEmpty) {
        print('📍 No placemarks found, using coordinates as address');
        // Return location with just coordinates
        return LocationEntity(
          latitude: latitude,
          longitude: longitude,
          address: '$latitude, $longitude',
          timestamp: DateTime.now(),
        );
      }

      final place = placemarks.first;
      print(
        '📍 Placemark: locality=${place.locality}, administrativeArea=${place.administrativeArea}, country=${place.country}',
      );

      // Build address string
      final addressParts = <String>[];
      if (place.subLocality?.isNotEmpty == true) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality?.isNotEmpty == true) {
        addressParts.add(place.locality!);
      }
      if (place.administrativeArea?.isNotEmpty == true) {
        addressParts.add(place.administrativeArea!);
      }
      if (place.country?.isNotEmpty == true) {
        addressParts.add(place.country!);
      }

      final address = addressParts.isNotEmpty
          ? addressParts.join(', ')
          : '$latitude, $longitude';

      return LocationEntity(
        latitude: latitude,
        longitude: longitude,
        address: address,
        city: place.locality,
        state: place.administrativeArea,
        country: place.country,
        postalCode: place.postalCode,
        timestamp: DateTime.now(),
      );
    } on SocketException {
      throw const LocationNetworkFailure();
    } on TimeoutException {
      throw const LocationNetworkFailure(
        'Address lookup timed out. Check your internet connection.',
      );
    } catch (e) {
      if (e is LocationNetworkFailure) rethrow;
      throw GeocodingFailure('Failed to get address: $e');
    }
  }
}
