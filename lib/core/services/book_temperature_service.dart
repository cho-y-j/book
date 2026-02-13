import 'dart:math';

/// 책다리 온도 계산 서비스
class BookTemperatureService {
  BookTemperatureService._();

  static const double initialTemperature = 36.5;
  static const double minTemperature = 0.0;
  static const double maxTemperature = 100.0;

  // 가산 요소
  static const double exchangeComplete = 0.5;
  static const double reviewHighRating = 0.3; // 4.5 이상
  static const double reviewGoodRating = 0.1; // 4.0 이상
  static const double relayExchangeSuccess = 0.7;
  static const double bookClubActivity = 0.2;

  // 감산 요소
  static const double exchangeNoShow = -2.0;
  static const double reportConfirmed = -3.0;
  static const double reviewLowRating = -0.5; // 2.0 이하
  static const double exchangeCancelAfterMatch = -0.3;

  /// 교환 완료 후 온도 업데이트
  static double afterExchangeComplete(double currentTemp) {
    return _clamp(currentTemp + exchangeComplete);
  }

  /// 후기 평점에 따른 온도 업데이트
  static double afterReview(double currentTemp, double rating) {
    if (rating >= 4.5) return _clamp(currentTemp + reviewHighRating);
    if (rating >= 4.0) return _clamp(currentTemp + reviewGoodRating);
    if (rating <= 2.0) return _clamp(currentTemp + reviewLowRating);
    return currentTemp;
  }

  /// 노쇼 발생 시
  static double afterNoShow(double currentTemp) {
    return _clamp(currentTemp + exchangeNoShow);
  }

  /// 신고 확인 시
  static double afterReportConfirmed(double currentTemp) {
    return _clamp(currentTemp + reportConfirmed);
  }

  /// 릴레이 교환 성공 시
  static double afterRelayExchange(double currentTemp) {
    return _clamp(currentTemp + relayExchangeSuccess);
  }

  /// 매칭 후 취소 시
  static double afterCancelAfterMatch(double currentTemp) {
    return _clamp(currentTemp + exchangeCancelAfterMatch);
  }

  /// 책모임 활동 시
  static double afterBookClubActivity(double currentTemp) {
    return _clamp(currentTemp + bookClubActivity);
  }

  static double _clamp(double value) {
    return max(minTemperature, min(maxTemperature, value));
  }
}
