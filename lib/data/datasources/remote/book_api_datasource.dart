import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';

class BookApiDatasource {
  final Dio _dio;
  BookApiDatasource({Dio? dio}) : _dio = dio ?? Dio();

  /// 알라딘 API로 ISBN 검색
  Future<Map<String, dynamic>?> searchByIsbn(String isbn) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.aladinBaseUrl}/ItemLookUp.aspx',
        queryParameters: {
          'ttbkey': ApiConstants.aladinApiKey,
          'ItemId': isbn,
          'ItemIdType': 'ISBN13',
          'output': 'js',
          'Version': '20131101',
          'Cover': 'Big',
        },
      );
      if (response.statusCode == 200 && response.data['item'] != null) {
        final items = response.data['item'] as List;
        return items.isNotEmpty ? items.first as Map<String, dynamic> : null;
      }
      return null;
    } catch (e) {
      throw ServerException(message: '책 정보 조회 실패: $e');
    }
  }

  /// 알라딘 API로 제목 검색
  Future<List<Map<String, dynamic>>> searchByTitle(String title) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.aladinBaseUrl}/ItemSearch.aspx',
        queryParameters: {
          'ttbkey': ApiConstants.aladinApiKey,
          'Query': title,
          'QueryType': 'Title',
          'MaxResults': 20,
          'start': 1,
          'SearchTarget': 'Book',
          'output': 'js',
          'Version': '20131101',
          'Cover': 'Big',
        },
      );
      if (response.statusCode == 200 && response.data['item'] != null) {
        return (response.data['item'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw ServerException(message: '책 검색 실패: $e');
    }
  }

  /// 알라딘 API로 베스트셀러 조회
  Future<List<Map<String, dynamic>>> getBestsellers({String categoryId = '0'}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.aladinBaseUrl}/ItemList.aspx',
        queryParameters: {
          'ttbkey': ApiConstants.aladinApiKey,
          'QueryType': 'Bestseller',
          'MaxResults': 20,
          'start': 1,
          'SearchTarget': 'Book',
          'CategoryId': categoryId,
          'output': 'js',
          'Version': '20131101',
          'Cover': 'Big',
        },
      );
      if (response.statusCode == 200 && response.data['item'] != null) {
        return (response.data['item'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw ServerException(message: '베스트셀러 조회 실패: $e');
    }
  }
}
