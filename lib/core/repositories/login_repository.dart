// ariana
import 'package:tusfind_frontend/core/services/api_service.dart';

class LoginRepository {
  final ApiService api;

  LoginRepository(this.api);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Mengirim request POST ke endpoint /login
      final response = await api.post('/login', {
        'email': email,
        'password': password,
      });

      // Mengembalikan data response (biasanya berisi token dan user)
      return response.data;
    } catch (e) {
      // Melempar error agar bisa ditangkap oleh UI
      rethrow;
    }
  }
}