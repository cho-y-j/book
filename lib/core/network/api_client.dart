import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) {
    return _dio.delete<T>(path, options: options);
  }
}
