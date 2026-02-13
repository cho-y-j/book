import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';

class BookApiDatasource {
  final Dio _dio;
  BookApiDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// 알라딘 API로 ISBN 검색
  Future<Map<String, dynamic>?> searchByIsbn(String isbn) async {
    try {
      final response = await _dio.get(ApiConstants.aladinBaseUrl, queryParameters: {
        'ttbkey': ApiConstants.aladinApiKey, 'ItemId': isbn, 'ItemIdType': 'ISBN13',
        'output': 'js', 'Version': '20131101', 'Cover': 'Big',
      });
      if (response.statusCode == 200 && response.data['item'] != null) {
        final items = response.data['item'] as List;
        return items.isNotEmpty ? items.first as Map<String, dynamic> : null;
      }
      return null;
    } catch (e) { throw ServerException(message: '책 정보 조회 실패: $e'); }
  }

  /// 네이버 API로 제목 검색
  Future<List<Map<String, dynamic>>> searchByTitle(String title) async {
    try {
      final response = await _dio.get(ApiConstants.naverBaseUrl, queryParameters: {'query': title, 'display': 20},
        options: Options(headers: {'X-Naver-Client-Id': ApiConstants.naverClientId, 'X-Naver-Client-Secret': ApiConstants.naverClientSecret}));
      if (response.statusCode == 200) {
        return (response.data['items'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) { throw ServerException(message: '책 검색 실패: $e'); }
  }

  /// 카카오 API로 검색
  Future<List<Map<String, dynamic>>> searchKakao(String query) async {
    try {
      final response = await _dio.get(ApiConstants.kakaoBaseUrl, queryParameters: {'query': query, 'size': 20},
        options: Options(headers: {'Authorization': 'KakaoAK ${ApiConstants.kakaoRestApiKey}'}));
      if (response.statusCode == 200) {
        return (response.data['documents'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) { throw ServerException(message: '카카오 검색 실패: $e'); }
  }
}
