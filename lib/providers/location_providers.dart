import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';

final selectedLocationProvider = StateProvider<String>((ref) {
  return '서울시 강남구';
});

final selectedDistanceProvider = StateProvider<double>((ref) {
  return 5000; // 5km
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentPositionProvider = FutureProvider<Position?>((ref) async {
  try {
    return await ref.watch(locationServiceProvider).getCurrentPosition();
  } catch (_) {
    return null;
  }
});

final currentAddressProvider = FutureProvider<Map<String, String>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  if (position == null) return {'region': '', 'subRegion': '', 'fullAddress': ''};
  return ref.watch(locationServiceProvider).reverseGeocode(
    position.latitude,
    position.longitude,
  );
});
