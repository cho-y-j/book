import '../constants/enums.dart';

/// 레벨 & 뱃지 시스템
class LevelBadgeService {
  LevelBadgeService._();

  /// 교환 횟수로 레벨 계산
  static UserLevel calculateLevel(int exchangeCount) {
    return UserLevel.fromExchangeCount(exchangeCount);
  }

  /// 뱃지 획득 여부 확인
  static List<String> checkNewBadges({
    required List<String> currentBadges,
    required int totalExchanges,
    required int consecutiveLoginDays,
    required int uniqueGenresExchanged,
    required int relayExchangeCount,
    required double averageRating,
    required int ratingCount,
    required int bookClubsHosted,
    required double acceptRate,
    required int communityContributions,
    required DateTime joinDate,
    required DateTime serviceStartDate,
  }) {
    final newBadges = <String>[];

    // 첫 교환
    if (totalExchanges >= 1 && !currentBadges.contains('first_exchange')) {
      newBadges.add('first_exchange');
    }

    // 연속왕 (7일 연속 로그인)
    if (consecutiveLoginDays >= 7 && !currentBadges.contains('streak')) {
      newBadges.add('streak');
    }

    // 장르탐험가 (5개 이상 장르)
    if (uniqueGenresExchanged >= 5 && !currentBadges.contains('genre_explorer')) {
      newBadges.add('genre_explorer');
    }

    // 릴레이킹 (3회 이상)
    if (relayExchangeCount >= 3 && !currentBadges.contains('relay_king')) {
      newBadges.add('relay_king');
    }

    // 별점왕 (평균 4.8 이상, 10회 이상)
    if (averageRating >= 4.8 && ratingCount >= 10 && !currentBadges.contains('star')) {
      newBadges.add('star');
    }

    // 에코히어로 (50권 이상)
    if (totalExchanges >= 50 && !currentBadges.contains('eco_hero')) {
      newBadges.add('eco_hero');
    }

    // 책모임장 (3회 이상 개최)
    if (bookClubsHosted >= 3 && !currentBadges.contains('club_leader')) {
      newBadges.add('club_leader');
    }

    // 매칭마스터 (수락률 90% 이상)
    if (acceptRate >= 0.9 && totalExchanges >= 10 && !currentBadges.contains('matching_master')) {
      newBadges.add('matching_master');
    }

    // 초기멤버 (런칭 후 1개월 내 가입)
    final earlyBirdDeadline = serviceStartDate.add(const Duration(days: 30));
    if (joinDate.isBefore(earlyBirdDeadline) && !currentBadges.contains('early_bird')) {
      newBadges.add('early_bird');
    }

    // 등록왕 (커뮤니티 DB 10권 이상)
    if (communityContributions >= 10 && !currentBadges.contains('contributor')) {
      newBadges.add('contributor');
    }

    return newBadges;
  }

  /// 뱃지 이름 → 표시 이름
  static String badgeDisplayName(String badgeId) {
    switch (badgeId) {
      case 'first_exchange': return '첫 교환';
      case 'streak': return '연속왕';
      case 'genre_explorer': return '장르탐험가';
      case 'relay_king': return '릴레이킹';
      case 'star': return '별점왕';
      case 'eco_hero': return '에코히어로';
      case 'club_leader': return '책모임장';
      case 'matching_master': return '매칭마스터';
      case 'early_bird': return '초기멤버';
      case 'contributor': return '등록왕';
      default: return badgeId;
    }
  }

  /// 뱃지 이모지
  static String badgeEmoji(String badgeId) {
    switch (badgeId) {
      case 'first_exchange': return '\u{1F4DA}';
      case 'streak': return '\u{1F525}';
      case 'genre_explorer': return '\u{1F308}';
      case 'relay_king': return '\u{1F91D}';
      case 'star': return '\u{2B50}';
      case 'eco_hero': return '\u{1F331}';
      case 'club_leader': return '\u{1F4D6}';
      case 'matching_master': return '\u{1F3AF}';
      case 'early_bird': return '\u{1F48E}';
      case 'contributor': return '\u{1F4F8}';
      default: return '\u{1F3C6}';
    }
  }
}
