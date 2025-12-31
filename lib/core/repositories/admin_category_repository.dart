import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

class AdminCategoryRepository {
  final ApiService api;

  AdminCategoryRepository(this.api);

  Future<List<Category>> getCategories() async {
    final response = await api.get('/categories');

    final List data = response.data['data'];
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createCategory(String name, String? description) async {
    final response = await api.post('/categories', {
      'name': name,
      'description': description,
    });

    return Category.fromJson(response.data['data']);
  }

  Future<Category> updateCategory(int id, String name, String? description) async {
    final response = await api.put('/categories/$id', {
      'name': name,
      'description': description,
    });

    return Category.fromJson(response.data['data']);
  }

  Future<void> deleteCategory(int id) async {
    await api.delete('/categories/$id');
  }
}