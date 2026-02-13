import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/services/point_service.dart';

void main() {
  group('PointService', () {
    test('책 기부 등록 시 +100P', () {
      final result = PointService.calculatePoints(currentPoints: 0, event: PointEvent.bookDonation);
      expect(result, 100);
    });

    test('교환 완료 시 +50P', () {
      final result = PointService.calculatePoints(currentPoints: 100, event: PointEvent.exchangeComplete);
      expect(result, 150);
    });

    test('후기 작성 시 +10P', () {
      final result = PointService.calculatePoints(currentPoints: 50, event: PointEvent.reviewWritten);
      expect(result, 60);
    });

    test('커뮤니티 DB 기여 시 +30P', () {
      final result = PointService.calculatePoints(currentPoints: 0, event: PointEvent.communityDbContribution);
      expect(result, 30);
    });

    test('일일 출석 시 +5P', () {
      final result = PointService.calculatePoints(currentPoints: 200, event: PointEvent.dailyAttendance);
      expect(result, 205);
    });

    test('인기도 높은 책 가져가기 비용 300P', () {
      expect(PointService.pointsToTakeBook(25), 300);
    });

    test('인기도 중간 책 가져가기 비용 200P', () {
      expect(PointService.pointsToTakeBook(15), 200);
    });

    test('인기도 낮은 책 가져가기 비용 100P', () {
      expect(PointService.pointsToTakeBook(5), 100);
    });
  });
}
