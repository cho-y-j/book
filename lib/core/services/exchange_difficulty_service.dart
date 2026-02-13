/// 교환 난이도 계산
class ExchangeDifficultyService {
  ExchangeDifficultyService._();

  /// 교환 난이도 계산
  /// ratio = wishlistCount / availableCount
  static ExchangeDifficultyLevel calculate({
    required int wishlistCount,
    required int availableCount,
  }) {
    if (availableCount == 0) {
      return wishlistCount > 0
          ? ExchangeDifficultyLevel.high
          : ExchangeDifficultyLevel.low;
    }

    final ratio = wishlistCount / availableCount;
    if (ratio > 5) return ExchangeDifficultyLevel.high;
    if (ratio >= 1) return ExchangeDifficultyLevel.medium;
    return ExchangeDifficultyLevel.low;
  }
}

enum ExchangeDifficultyLevel {
  high('높음', '\u{1F534}'),
  medium('보통', '\u{1F7E1}'),
  low('낮음', '\u{1F7E2}');

  const ExchangeDifficultyLevel(this.label, this.emoji);
  final String label;
  final String emoji;
}
