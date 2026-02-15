class BarcodeService {
  /// ISBN 유효성 검사 (ISBN-10 또는 ISBN-13)
  static bool isValidIsbn(String isbn) {
    final cleaned = isbn.replaceAll('-', '');
    return cleaned.length == 10 || cleaned.length == 13;
  }

  /// 스캔된 바코드를 ISBN-13으로 정규화. 유효하지 않으면 null.
  static String? normalizeIsbn(String rawValue) {
    final cleaned = rawValue.replaceAll('-', '').trim();
    if (cleaned.length == 13 && (cleaned.startsWith('978') || cleaned.startsWith('979'))) {
      return cleaned;
    }
    if (cleaned.length == 10) {
      return convertIsbn10to13(cleaned);
    }
    return null;
  }

  /// ISBN-10을 ISBN-13으로 변환
  static String? convertIsbn10to13(String isbn10) {
    if (isbn10.length != 10) return null;
    final prefix = '978${isbn10.substring(0, 9)}';
    int sum = 0;
    for (int i = 0; i < 12; i++) { sum += int.parse(prefix[i]) * (i.isEven ? 1 : 3); }
    final checkDigit = (10 - (sum % 10)) % 10;
    return '$prefix$checkDigit';
  }
}
