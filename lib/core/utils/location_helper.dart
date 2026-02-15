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

  /// 17개 시/도 리스트
  static const List<String> koreanRegions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원특별자치도',
    '충청북도',
    '충청남도',
    '전북특별자치도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  /// 주소에서 시/도 추출
  static String? extractRegion(String address) {
    for (final region in koreanRegions) {
      if (address.contains(region)) return region;
    }
    // 축약형 매칭 (서울, 부산 등)
    const shortNames = {
      '서울': '서울특별시',
      '부산': '부산광역시',
      '대구': '대구광역시',
      '인천': '인천광역시',
      '광주': '광주광역시',
      '대전': '대전광역시',
      '울산': '울산광역시',
      '세종': '세종특별자치시',
      '경기': '경기도',
      '강원': '강원특별자치도',
      '충북': '충청북도',
      '충남': '충청남도',
      '전북': '전북특별자치도',
      '전남': '전라남도',
      '경북': '경상북도',
      '경남': '경상남도',
      '제주': '제주특별자치도',
    };
    for (final entry in shortNames.entries) {
      if (address.contains(entry.key)) return entry.value;
    }
    return null;
  }

  /// 주소에서 시/군/구 추출
  static String? extractSubRegion(String address) {
    final regex = RegExp(r'(\S+[시군구])');
    final matches = regex.allMatches(address).toList();
    // 특별시/광역시를 건너뛰고 첫 번째 하위 지역 반환
    for (final match in matches) {
      final m = match.group(1)!;
      if (!m.contains('특별') && !m.contains('광역')) return m;
    }
    return null;
  }
}
