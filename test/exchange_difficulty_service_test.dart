import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/services/exchange_difficulty_service.dart';

void main() {
  group('ExchangeDifficultyService', () {
    test('위시리스트/등록 비율 > 5이면 높음', () {
      final result = ExchangeDifficultyService.calculate(wishlistCount: 30, availableCount: 5);
      expect(result, ExchangeDifficultyLevel.high);
    });

    test('위시리스트/등록 비율 1~5이면 보통', () {
      final result = ExchangeDifficultyService.calculate(wishlistCount: 10, availableCount: 5);
      expect(result, ExchangeDifficultyLevel.medium);
    });

    test('위시리스트/등록 비율 < 1이면 낮음', () {
      final result = ExchangeDifficultyService.calculate(wishlistCount: 2, availableCount: 10);
      expect(result, ExchangeDifficultyLevel.low);
    });

    test('등록 0개, 위시리스트 있으면 높음', () {
      final result = ExchangeDifficultyService.calculate(wishlistCount: 5, availableCount: 0);
      expect(result, ExchangeDifficultyLevel.high);
    });

    test('둘 다 0이면 낮음', () {
      final result = ExchangeDifficultyService.calculate(wishlistCount: 0, availableCount: 0);
      expect(result, ExchangeDifficultyLevel.low);
    });
  });
}
