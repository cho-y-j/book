import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';

class DeliveryApiDatasource {
  final Dio _dio;
  DeliveryApiDatasource({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> trackDelivery(String carrier, String trackingNumber) async {
    try {
      final response = await _dio.post('https://apis.tracker.delivery/graphql', data: {
        'query': '''query { track(carrierId: "$carrier", trackingNumber: "$trackingNumber") { lastEvent { time status { code } description } events { time status { code } description } } }''',
      });
      if (response.statusCode == 200) return response.data['data']['track'] ?? {};
      return {};
    } catch (e) { throw ServerException(message: '배송 추적 실패: $e'); }
  }
}
