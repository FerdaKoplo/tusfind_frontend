// ariana 
import 'package:tusfind_frontend/core/services/api_service.dart';

class RegisterRepository {
  final ApiService api;

  RegisterRepository(this.api);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await api.post('/register', {
        'name': name,
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}