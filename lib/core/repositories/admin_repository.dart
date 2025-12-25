// ariana 

import 'package:tusfind_frontend/core/services/api_service.dart';
import '../models/admin_model.dart';

class AdminRepository {
  final ApiService api;

  AdminRepository(this.api);

  Future<AdminDashboard> getDashboardStats() async {
    final response = await api.get('/admin/stats');
    // Mengikuti pola teman Anda: response.data['data']
    return AdminDashboard.fromJson(response.data['data']);
  }
  
  Future<void> updateItemStatus(int id, String status) async {
    await api.put('/admin/items/$id', {'status': status});
  }
}