import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('temperature 포맷', () {
      expect(Formatters.temperature(36.5), '36.5°C');
      expect(Formatters.temperature(100.0), '100.0°C');
    });

    test('distance 포맷 - 미터', () {
      expect(Formatters.distance(500), '500m');
    });

    test('distance 포맷 - 킬로미터', () {
      expect(Formatters.distance(1500), '1.5km');
    });

    test('bookConditionLabel', () {
      expect(Formatters.bookConditionLabel('best'), '최상');
      expect(Formatters.bookConditionLabel('good'), '상');
      expect(Formatters.bookConditionLabel('fair'), '중');
      expect(Formatters.bookConditionLabel('poor'), '하');
    });

    test('numberFormat', () {
      expect(Formatters.numberFormat(1000), '1,000');
      expect(Formatters.numberFormat(1234567), '1,234,567');
    });

    test('dateToString', () {
      final date = DateTime(2026, 2, 13);
      expect(Formatters.dateToString(date), '2026.02.13');
    });
  });
}
