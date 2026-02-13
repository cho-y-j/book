import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String dateToString(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  static String dateTimeToString(DateTime dateTime) {
    return DateFormat('yyyy.MM.dd HH:mm').format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}년 전';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}개월 전';
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
    return '방금 전';
  }

  static String temperature(double temp) {
    return '${temp.toStringAsFixed(1)}°C';
  }

  static String distance(double meters) {
    if (meters < 1000) return '${meters.toInt()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  static String bookConditionLabel(String condition) {
    switch (condition) {
      case 'best':
        return '최상';
      case 'good':
        return '상';
      case 'fair':
        return '중';
      case 'poor':
        return '하';
      default:
        return condition;
    }
  }

  static String numberFormat(int number) {
    return NumberFormat('#,###').format(number);
  }

  static String ecoImpact(int exchangeCount) {
    final paperSaved = exchangeCount * 200; // grams
    final co2Saved = (exchangeCount * 1.2).toStringAsFixed(1); // kg
    return '종이 ${numberFormat(paperSaved)}g 절약, CO₂ ${co2Saved}kg 절감';
  }
}
