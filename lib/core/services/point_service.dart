/// 포인트 시스템
class PointService {
  PointService._();

  // 포인트 획득
  static const int bookDonation = 100;
  static const int exchangeComplete = 50;
  static const int reviewWritten = 10;
  static const int communityDbContribution = 30;
  static const int dailyAttendance = 5;

  // 포인트 사용 (책 인기도에 따라 100~300)
  static int pointsToTakeBook(int wishlistCount) {
    if (wishlistCount > 20) return 300;
    if (wishlistCount > 10) return 200;
    return 100;
  }

  static int calculatePoints({
    required int currentPoints,
    required PointEvent event,
  }) {
    switch (event) {
      case PointEvent.bookDonation:
        return currentPoints + bookDonation;
      case PointEvent.exchangeComplete:
        return currentPoints + exchangeComplete;
      case PointEvent.reviewWritten:
        return currentPoints + reviewWritten;
      case PointEvent.communityDbContribution:
        return currentPoints + communityDbContribution;
      case PointEvent.dailyAttendance:
        return currentPoints + dailyAttendance;
    }
  }
}

enum PointEvent {
  bookDonation,
  exchangeComplete,
  reviewWritten,
  communityDbContribution,
  dailyAttendance,
}
