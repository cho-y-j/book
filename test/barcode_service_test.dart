import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/services/barcode_service.dart';

void main() {
  group('BarcodeService', () {
    test('유효한 ISBN-13 검증', () {
      expect(BarcodeService.isValidIsbn('9788937460470'), isTrue);
    });

    test('유효한 ISBN-10 검증', () {
      expect(BarcodeService.isValidIsbn('8937460470'), isTrue);
    });

    test('길이가 10 또는 13이 아니면 무효', () {
      expect(BarcodeService.isValidIsbn('123456'), isFalse);
    });

    test('빈 문자열 무효', () {
      expect(BarcodeService.isValidIsbn(''), isFalse);
    });

    test('하이픈 포함 ISBN도 유효', () {
      expect(BarcodeService.isValidIsbn('978-89-374-6047-0'), isTrue);
    });

    test('ISBN-10을 ISBN-13으로 변환', () {
      final result = BarcodeService.convertIsbn10to13('8937460470');
      expect(result, isNotNull);
      expect(result!.length, 13);
      expect(result.startsWith('978'), isTrue);
    });

    test('ISBN-10 길이가 10이 아니면 null 반환', () {
      expect(BarcodeService.convertIsbn10to13('12345'), isNull);
    });

    test('normalizeIsbn - ISBN-13 정규화', () {
      expect(BarcodeService.normalizeIsbn('9788937460470'), '9788937460470');
    });

    test('normalizeIsbn - ISBN-10 → ISBN-13 변환', () {
      final result = BarcodeService.normalizeIsbn('8937460470');
      expect(result, isNotNull);
      expect(result!.length, 13);
    });

    test('normalizeIsbn - 유효하지 않은 값은 null', () {
      expect(BarcodeService.normalizeIsbn('12345'), isNull);
      expect(BarcodeService.normalizeIsbn('hello'), isNull);
    });
  });
}
