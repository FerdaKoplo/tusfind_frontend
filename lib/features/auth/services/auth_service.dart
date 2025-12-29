import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const FlutterSecureStorage _staticStorage =
      FlutterSecureStorage();

  AuthService(this._apiService);

  // REGISTER
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

  // LOGIN
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

    await _staticStorage.write(key: 'token', value: token);
    await _staticStorage.write(key: 'role', value: role);
  }

  // ====== UNTUK AUTH GUARD ======
  static Future<String?> getStoredToken() async {
    return await _staticStorage.read(key: 'token');
  }

  static Future<String?> getStoredRole() async {
    return await _staticStorage.read(key: 'role');
  }

  static Future<void> logout() async {
    await _staticStorage.deleteAll();
  }
}
