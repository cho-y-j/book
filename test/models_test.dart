import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/constants/enums.dart';

void main() {
  group('BookCondition enum', () {
    test('모든 condition에 label 존재', () {
      for (final c in BookCondition.values) {
        expect(c.label.isNotEmpty, isTrue);
      }
    });

    test('4가지 상태 존재', () {
      expect(BookCondition.values.length, 4);
    });

    test('최상/상/중/하 라벨', () {
      expect(BookCondition.best.label, '최상');
      expect(BookCondition.good.label, '상');
      expect(BookCondition.fair.label, '중');
      expect(BookCondition.poor.label, '하');
    });
  });

  group('ExchangeType enum', () {
    test('직거래만 label', () {
      expect(ExchangeType.localOnly.label, '직거래만');
    });

    test('택배만 label', () {
      expect(ExchangeType.deliveryOnly.label, '택배만');
    });

    test('모두 label', () {
      expect(ExchangeType.both.label, '모두');
    });
  });

  group('BookGenre enum', () {
    test('14개 장르 존재', () {
      expect(BookGenre.values.length, 14);
    });

    test('모든 장르에 label 존재', () {
      for (final genre in BookGenre.values) {
        expect(genre.label.isNotEmpty, isTrue);
      }
    });

    test('소설 장르 존재', () {
      expect(BookGenre.values.any((g) => g.label == '소설'), isTrue);
    });
  });

  group('UserLevel enum', () {
    test('fromExchangeCount 0~2회 새싹 독서가', () {
      expect(UserLevel.fromExchangeCount(0), UserLevel.sprout);
      expect(UserLevel.fromExchangeCount(2), UserLevel.sprout);
    });

    test('fromExchangeCount 3~9회 책벌레', () {
      expect(UserLevel.fromExchangeCount(3), UserLevel.bookworm);
      expect(UserLevel.fromExchangeCount(9), UserLevel.bookworm);
    });

    test('fromExchangeCount 10~29회 메이트', () {
      expect(UserLevel.fromExchangeCount(10), UserLevel.mate);
      expect(UserLevel.fromExchangeCount(29), UserLevel.mate);
    });

    test('fromExchangeCount 30~99회 마스터', () {
      expect(UserLevel.fromExchangeCount(30), UserLevel.master);
      expect(UserLevel.fromExchangeCount(99), UserLevel.master);
    });

    test('fromExchangeCount 100회 이상 전설', () {
      expect(UserLevel.fromExchangeCount(100), UserLevel.legend);
      expect(UserLevel.fromExchangeCount(500), UserLevel.legend);
    });

    test('5개 레벨 존재', () {
      expect(UserLevel.values.length, 5);
    });
  });

  group('ExchangeDifficulty enum', () {
    test('label 반환 확인', () {
      expect(ExchangeDifficulty.high.label, '높음');
      expect(ExchangeDifficulty.medium.label, '보통');
      expect(ExchangeDifficulty.low.label, '낮음');
    });
  });

  group('BookStatus enum', () {
    test('4개 상태 존재', () {
      expect(BookStatus.values.length, 4);
    });
  });

  group('NotificationType enum', () {
    test('알림 타입 5개 이상 존재', () {
      expect(NotificationType.values.length, greaterThanOrEqualTo(5));
    });
  });

  group('MessageType enum', () {
    test('메시지 타입 존재', () {
      expect(MessageType.values, contains(MessageType.text));
      expect(MessageType.values, contains(MessageType.image));
    });
  });

  group('SortOption enum', () {
    test('정렬 옵션에 label 존재', () {
      for (final option in SortOption.values) {
        expect(option.label.isNotEmpty, isTrue);
      }
    });
  });
}
