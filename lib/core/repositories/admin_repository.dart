// ariana

import 'package:tusfind_frontend/core/services/api_service.dart';
import '../models/admin_model.dart';

class AdminRepository {
  final ApiService api;

  AdminRepository(this.api);

  Future<AdminDashboard> getDashboardStats() async {
    final response = await api.get('/admin/stats');

    return AdminDashboard.fromJson(response.data);
  }

}
