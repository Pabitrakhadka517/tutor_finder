import 'package:equatable/equatable.dart';

/// Represents a geographic location with coordinates and human-readable address
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final DateTime? timestamp;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.timestamp,
  });

  /// Creates an empty/unknown location
  factory LocationEntity.unknown() => const LocationEntity(
    latitude: 0.0,
    longitude: 0.0,
    address: 'Unknown Location',
  );

  /// Check if location is valid
  bool get isValid => latitude != 0.0 || longitude != 0.0;

  /// Returns a formatted full address
  String get fullAddress {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.isNotEmpty ? parts.join(', ') : address;
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    address,
    city,
    state,
    country,
    postalCode,
    timestamp,
  ];
}
