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
}
