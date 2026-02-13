import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/core/constants/api_constants.dart';
import 'package:book_bridge/data/datasources/remote/book_api_datasource.dart';

void main() {
  late BookApiDatasource datasource;

  setUp(() {
    datasource = BookApiDatasource();
  });

  group('알라딘 API 테스트', () {
    test('API 키가 올바르게 로드되는지 확인', () {
      print('\n=== API 설정 확인 ===');
      print('Base URL: ${ApiConstants.aladinBaseUrl}');
      print('API Key: ${ApiConstants.aladinApiKey.isNotEmpty ? "로드됨 (${ApiConstants.aladinApiKey.substring(0, 6)}...)" : "비어있음!"}');
      expect(ApiConstants.aladinApiKey, isNotEmpty);
    });

    test('ISBN으로 도서 검색 (소년이 온다 - 한강)', () async {
      final result = await datasource.searchByIsbn('9788936434120');
      print('\n=== ISBN 검색 결과 ===');
      print('제목: ${result?['title']}');
      print('저자: ${result?['author']}');
      print('출판사: ${result?['publisher']}');
      print('가격: ${result?['priceStandard']}원');
      print('표지: ${result?['cover']}');
      print('ISBN13: ${result?['isbn13']}');
      print('카테고리: ${result?['categoryName']}');
      expect(result, isNotNull);
      expect(result?['title'], contains('소년이 온다'));
    });

    test('제목으로 도서 검색 (해리포터)', () async {
      final results = await datasource.searchByTitle('해리포터');
      print('\n=== 제목 검색 결과 (해리포터) ===');
      print('검색 결과: ${results.length}건');
      for (final item in results.take(5)) {
        print('- ${item['title']} | ${item['author']} | ${item['publisher']}');
      }
      expect(results, isNotEmpty);
    });

    test('베스트셀러 조회', () async {
      final results = await datasource.getBestsellers();
      print('\n=== 베스트셀러 ===');
      print('결과: ${results.length}건');
      for (final (i, item) in results.take(5).indexed) {
        print('${i + 1}. ${item['title']} | ${item['author']}');
      }
      expect(results, isNotEmpty);
    });
  });
}
