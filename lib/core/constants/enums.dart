/// 책 상태
enum BookCondition {
  best('최상'),
  good('상'),
  fair('중'),
  poor('하');

  const BookCondition(this.label);
  final String label;
}

/// 책 등록 상태
enum BookStatus {
  available('교환가능'),
  reserved('예약중'),
  exchanged('교환완료'),
  hidden('숨김');

  const BookStatus(this.label);
  final String label;
}

/// 교환 방식
enum ExchangeType {
  localOnly('직거래만'),
  deliveryOnly('택배만'),
  both('모두');

  const ExchangeType(this.label);
  final String label;
}

/// 교환 요청 상태
enum ExchangeRequestStatus {
  pending,
  viewing,
  matched,
  rejected,
  cancelled,
  completed,
}

/// 매칭 상태
enum MatchStatus {
  confirmed,
  inProgress,
  completed,
  cancelled,
}

/// 배송 상태
enum DeliveryStatus {
  pending,
  shipped,
  inTransit,
  delivered,
}

/// 메시지 타입
enum MessageType {
  text,
  image,
  system,
  location,
}

/// 알림 타입
enum NotificationType {
  exchangeRequest,
  match,
  chat,
  wishlistMatch,
  review,
  delivery,
  system,
  relay,
  levelUp,
  badge,
}

/// 신고 사유
enum ReportReason {
  fakeBook('허위 등록'),
  noShow('노쇼'),
  fraud('사기'),
  inappropriate('부적절'),
  spam('스팸'),
  other('기타');

  const ReportReason(this.label);
  final String label;
}

/// 신고 상태
enum ReportStatus { pending, reviewed, resolved }

/// 릴레이 교환 상태
enum RelayExchangeStatus {
  proposed,
  allConfirmed,
  inProgress,
  completed,
  cancelled,
}

/// 사용자 상태
enum UserStatus { active, suspended, deleted }

/// 교환 난이도
enum ExchangeDifficulty {
  high('높음'),
  medium('보통'),
  low('낮음');

  const ExchangeDifficulty(this.label);
  final String label;
}

/// 정렬 기준
enum SortOption {
  latest('최신순'),
  popular('인기순'),
  nearest('가까운순'),
  difficulty('교환난이도순');

  const SortOption(this.label);
  final String label;
}

/// 장르
enum BookGenre {
  all('전체'),
  novel('소설'),
  nonFiction('비소설'),
  selfHelp('자기계발'),
  business('경영'),
  science('과학'),
  it('IT'),
  comic('만화'),
  essay('에세이'),
  poetry('시'),
  history('역사'),
  children('어린이'),
  foreignLanguage('외국어'),
  other('기타');

  const BookGenre(this.label);
  final String label;
}

/// 사용자 레벨
enum UserLevel {
  sprout(1, '새싹 독서가', 0),
  bookworm(2, '책벌레', 3),
  mate(3, '책다리 메이트', 10),
  master(4, '책다리 마스터', 30),
  legend(5, '책다리 전설', 100);

  const UserLevel(this.value, this.label, this.minExchanges);
  final int value;
  final String label;
  final int minExchanges;

  static UserLevel fromExchangeCount(int count) {
    if (count >= 100) return legend;
    if (count >= 30) return master;
    if (count >= 10) return mate;
    if (count >= 3) return bookworm;
    return sprout;
  }
}
