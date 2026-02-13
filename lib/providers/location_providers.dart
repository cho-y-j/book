import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedLocationProvider = StateProvider<String>((ref) {
  return '서울시 강남구';
});

final selectedDistanceProvider = StateProvider<double>((ref) {
  return 5000; // 5km
});
