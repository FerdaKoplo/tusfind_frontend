import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/models/profile_model.dart';
import 'package:tusfind_frontend/core/models/user_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

class ProfileRepository {
  final ApiService api;

  ProfileRepository(this.api);

  Future<ProfileStats> getStats() async {
    try {
      final response = await api.get('/profile/stats');
      return ProfileStats.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUser() async {
    try {
      final response = await api.get('/profile');
      return User.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

}