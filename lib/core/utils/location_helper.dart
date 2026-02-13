class LocationHelper {
  LocationHelper._();

  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  static String shortenLocation(String location) {
    final parts = location.split(' ');
    if (parts.length >= 3) return '${parts[1]} ${parts[2]}';
    if (parts.length >= 2) return parts[1];
    return location;
  }
}
