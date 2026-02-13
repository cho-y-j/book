import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/services/book_temperature_service.dart';

void main() {
  group('BookTemperatureService', () {
    test('초기 온도는 36.5도', () {
      expect(BookTemperatureService.initialTemperature, 36.5);
    });

    test('교환 완료 시 +0.5도', () {
      final result = BookTemperatureService.afterExchangeComplete(36.5);
      expect(result, 37.0);
    });

    test('후기 4.5 이상 시 +0.3도', () {
      final result = BookTemperatureService.afterReview(36.5, 4.5);
      expect(result, 36.8);
    });

    test('후기 4.0 이상 시 +0.1도', () {
      final result = BookTemperatureService.afterReview(36.5, 4.2);
      expect(result, 36.6);
    });

    test('후기 2.0 이하 시 -0.5도', () {
      final result = BookTemperatureService.afterReview(36.5, 1.5);
      expect(result, 36.0);
    });

    test('후기 2.1~3.9 시 변화 없음', () {
      final result = BookTemperatureService.afterReview(36.5, 3.0);
      expect(result, 36.5);
    });

    test('노쇼 시 -2.0도', () {
      final result = BookTemperatureService.afterNoShow(36.5);
      expect(result, 34.5);
    });

    test('신고 확인 시 -3.0도', () {
      final result = BookTemperatureService.afterReportConfirmed(36.5);
      expect(result, 33.5);
    });

    test('릴레이 교환 성공 시 +0.7도', () {
      final result = BookTemperatureService.afterRelayExchange(36.5);
      expect(result, 37.2);
    });

    test('매칭 후 취소 시 -0.3도', () {
      final result = BookTemperatureService.afterCancelAfterMatch(36.5);
      expect(result, 36.2);
    });

    test('책모임 활동 시 +0.2도', () {
      final result = BookTemperatureService.afterBookClubActivity(36.5);
      expect(result, 36.7);
    });

    test('최소 온도 0도 이하로 내려가지 않음', () {
      final result = BookTemperatureService.afterReportConfirmed(1.0);
      expect(result, 0.0);
    });

    test('최대 온도 100도 이상으로 올라가지 않음', () {
      final result = BookTemperatureService.afterExchangeComplete(99.8);
      expect(result, 100.0);
    });
  });
}
