import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/services/level_badge_service.dart';
import 'package:book_bridge/core/constants/enums.dart';

void main() {
  group('LevelBadgeService', () {
    group('calculateLevel', () {
      test('0~2회 교환은 새싹 독서가', () {
        expect(LevelBadgeService.calculateLevel(0), UserLevel.sprout);
        expect(LevelBadgeService.calculateLevel(2), UserLevel.sprout);
      });

      test('3~9회 교환은 책벌레', () {
        expect(LevelBadgeService.calculateLevel(3), UserLevel.bookworm);
        expect(LevelBadgeService.calculateLevel(9), UserLevel.bookworm);
      });

      test('10~29회 교환은 책다리 메이트', () {
        expect(LevelBadgeService.calculateLevel(10), UserLevel.mate);
        expect(LevelBadgeService.calculateLevel(29), UserLevel.mate);
      });

      test('30~99회 교환은 책다리 마스터', () {
        expect(LevelBadgeService.calculateLevel(30), UserLevel.master);
        expect(LevelBadgeService.calculateLevel(99), UserLevel.master);
      });

      test('100회 이상은 책다리 전설', () {
        expect(LevelBadgeService.calculateLevel(100), UserLevel.legend);
        expect(LevelBadgeService.calculateLevel(500), UserLevel.legend);
      });
    });

    group('checkNewBadges', () {
      test('첫 교환 뱃지 획득', () {
        final badges = LevelBadgeService.checkNewBadges(
          currentBadges: [],
          totalExchanges: 1,
          consecutiveLoginDays: 0,
          uniqueGenresExchanged: 1,
          relayExchangeCount: 0,
          averageRating: 0,
          ratingCount: 0,
          bookClubsHosted: 0,
          acceptRate: 0,
          communityContributions: 0,
          joinDate: DateTime(2026, 3, 1),
          serviceStartDate: DateTime(2026, 1, 1),
        );
        expect(badges, contains('first_exchange'));
      });

      test('이미 가진 뱃지는 중복 획득 불가', () {
        final badges = LevelBadgeService.checkNewBadges(
          currentBadges: ['first_exchange'],
          totalExchanges: 1,
          consecutiveLoginDays: 0,
          uniqueGenresExchanged: 1,
          relayExchangeCount: 0,
          averageRating: 0,
          ratingCount: 0,
          bookClubsHosted: 0,
          acceptRate: 0,
          communityContributions: 0,
          joinDate: DateTime(2026, 3, 1),
          serviceStartDate: DateTime(2026, 1, 1),
        );
        expect(badges, isNot(contains('first_exchange')));
      });

      test('에코히어로 뱃지 (50권 이상)', () {
        final badges = LevelBadgeService.checkNewBadges(
          currentBadges: [],
          totalExchanges: 50,
          consecutiveLoginDays: 0,
          uniqueGenresExchanged: 0,
          relayExchangeCount: 0,
          averageRating: 0,
          ratingCount: 0,
          bookClubsHosted: 0,
          acceptRate: 0,
          communityContributions: 0,
          joinDate: DateTime(2026, 3, 1),
          serviceStartDate: DateTime(2026, 1, 1),
        );
        expect(badges, contains('eco_hero'));
        expect(badges, contains('first_exchange'));
      });

      test('초기멤버 뱃지 (런칭 30일 내 가입)', () {
        final badges = LevelBadgeService.checkNewBadges(
          currentBadges: [],
          totalExchanges: 0,
          consecutiveLoginDays: 0,
          uniqueGenresExchanged: 0,
          relayExchangeCount: 0,
          averageRating: 0,
          ratingCount: 0,
          bookClubsHosted: 0,
          acceptRate: 0,
          communityContributions: 0,
          joinDate: DateTime(2026, 1, 15),
          serviceStartDate: DateTime(2026, 1, 1),
        );
        expect(badges, contains('early_bird'));
      });
    });

    group('badgeDisplayName', () {
      test('뱃지 표시 이름 반환', () {
        expect(LevelBadgeService.badgeDisplayName('first_exchange'), '첫 교환');
        expect(LevelBadgeService.badgeDisplayName('eco_hero'), '에코히어로');
        expect(LevelBadgeService.badgeDisplayName('unknown'), 'unknown');
      });
    });
  });
}
