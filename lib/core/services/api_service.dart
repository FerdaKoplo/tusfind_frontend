import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ivan
class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _baseUrl = "http://10.0.2.2:8000";

  ApiService({String? token}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "$_baseUrl/api",
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print("API Error: ${e.response?.statusCode} - ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  String get storageUrl => "$_baseUrl/storage/";

  // ivan
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ivan
  Future<Response> post(String endpoint, dynamic data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ivan
  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception(e.response?.data['message'] ?? 'Server error');
    }
    return Exception('Connection error');
  }

  // ivan
  Future<Response> put(String endpoint, dynamic data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ivan
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
