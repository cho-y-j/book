import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class DeepSeekDatasource {
  final Dio _dio;
  DeepSeekDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// AI 답변 추천 생성
  /// 실패 시 빈 문자열 반환
  Future<String> generateReplySuggestion({
    required String bookTitle,
    required String transactionType,
    required List<String> recentMessages,
    bool isRequester = true,
  }) async {
    try {
      final typeLabel = switch (transactionType) {
        'sharing' => '나눔',
        'donation' => '기증',
        'exchange' => '교환',
        'sale' => '판매',
        _ => '거래',
      };

      final roleLabel = isRequester
          ? (transactionType == 'sale' ? '구매자' : '요청자')
          : (transactionType == 'sale' ? '판매자' : '제공자');

      final messagesContext = recentMessages.isNotEmpty
          ? recentMessages.map((m) => '- $m').join('\n')
          : '(아직 대화 없음)';

      final systemPrompt = '''당신은 중고책 거래 앱 "책가지"의 채팅 답변 도우미입니다.

현재 상황:
- 책: "$bookTitle"
- 거래 유형: $typeLabel
- 나의 역할: $roleLabel

규칙:
- 자연스럽고 예의 바른 한국어로 답변
- 반드시 1문장만 (40자 이내)
- 현재 대화 흐름에 맞는 다음 답변을 추천
- $typeLabel 거래에 적합한 내용 (인사, 상태 확인, 가격 협의, 수령 방법, 감사 등)
- 따옴표나 설명 없이 답변 텍스트만 출력''';

      final response = await _dio.post(
        '${ApiConstants.deepSeekBaseUrl}/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer ${ApiConstants.deepSeekApiKey}',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': '지금까지 대화 내용:\n$messagesContext\n\n$roleLabel로서 적절한 다음 답변 1문장:',
            },
          ],
          'max_tokens': 60,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final choices = response.data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String?)?.trim() ?? '';
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}
