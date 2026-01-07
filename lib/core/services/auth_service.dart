import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const FlutterSecureStorage _staticStorage = FlutterSecureStorage();

  AuthService(this._apiService);

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _apiService.post('/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    Response response = await _apiService.post('/login', {
      'email': email,
      'password': password,
    });

    final String token = response.data['token'];
    final String role = response.data['role'];
    final int userId = response.data['user']['id'];

    await _staticStorage.write(key: 'token', value: token);
    await _staticStorage.write(key: 'role', value: role);
    await _staticStorage.write(key: 'userId', value: userId.toString());
  }

  static Future<String?> getStoredToken() async {
    return await _staticStorage.read(key: 'token');
  }

  static Future<String?> getStoredRole() async {
    return await _staticStorage.read(key: 'role');
  }

  static Future<int?> getStoredUserId() async {
    String? id = await _staticStorage.read(key: 'userId');
    return id != null ? int.tryParse(id) : null;
  }

  static Future<void> logout() async {
    await _staticStorage.deleteAll();
  }
}
