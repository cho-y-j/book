import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class DeepSeekDatasource {
  final Dio _dio;
  DeepSeekDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// AI 답변 추천 생성 (최소 토큰)
  /// 실패 시 빈 문자열 반환
  Future<String> generateReplySuggestion({
    required String bookTitle,
    required String transactionType,
    required List<String> recentMessages,
  }) async {
    try {
      final typeLabel = switch (transactionType) {
        'sharing' => '나눔',
        'donation' => '기증',
        'exchange' => '교환',
        'sale' => '판매',
        _ => '거래',
      };

      final messagesContext = recentMessages.isNotEmpty
          ? recentMessages.map((m) => '- $m').join('\n')
          : '(대화 시작)';

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
              'content': '한국어 책 $typeLabel 앱 답변 도우미. 책: $bookTitle. 자연스럽고 짧은 한국어 답변 1개만.',
            },
            {
              'role': 'user',
              'content': '최근 대화:\n$messagesContext\n\n적절한 답변을 한 문장으로.',
            },
          ],
          'max_tokens': 50,
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
