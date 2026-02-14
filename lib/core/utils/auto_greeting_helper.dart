class AutoGreetingHelper {
  AutoGreetingHelper._();

  static String getGreeting({
    required String transactionType,
    required String bookTitle,
    int? price,
    String? orgWelcomeMessage,
  }) {
    return switch (transactionType) {
      'donation' => orgWelcomeMessage ?? '기증 감사합니다! 전달 방법을 선택해주세요.',
      'sharing' => '\'$bookTitle\' 나눔 채팅이 시작되었습니다. 수령 방법을 정해주세요!',
      'exchange' => '\'$bookTitle\' 교환 채팅입니다. 교환 조건을 이야기해보세요!',
      'sale' => '\'$bookTitle\' (${price ?? 0}원) 구매 채팅입니다.',
      _ => '채팅이 시작되었습니다.',
    };
  }
}
