import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('위치 서비스가 비활성화 되어 있습니다');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('위치 권한이 거부되었습니다');
    }
    if (permission == LocationPermission.deniedForever) throw Exception('위치 권한이 영구적으로 거부되었습니다');

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// 위도/경도 → 구조화된 주소 정보
  Future<Map<String, String>> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return {'region': '', 'subRegion': '', 'fullAddress': ''};
      }
      final p = placemarks.first;
      final region = p.administrativeArea ?? '';
      final subRegion = p.subAdministrativeArea?.isNotEmpty == true
          ? p.subAdministrativeArea!
          : (p.locality ?? '');
      final fullAddress = [
        p.administrativeArea,
        p.subAdministrativeArea,
        p.locality,
        p.subLocality,
        p.thoroughfare,
        p.subThoroughfare,
      ].where((e) => e != null && e.isNotEmpty).join(' ');
      return {
        'region': region,
        'subRegion': subRegion,
        'fullAddress': fullAddress,
      };
    } catch (_) {
      return {'region': '', 'subRegion': '', 'fullAddress': ''};
    }
  }

  /// 위도/경도 → 전체 주소 문자열
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    final result = await reverseGeocode(lat, lng);
    return result['fullAddress'] ?? '';
  }
}
