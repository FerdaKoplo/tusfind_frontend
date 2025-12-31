import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

// ivan
class CategoryRepository {
  final ApiService api;

  CategoryRepository(this.api);

  Future<List<Category>> getCategories() async {
    final response = await api.get('/categories');

    final List data = response.data['data'];
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> getCategoryDetail(int id) async {
    final response = await api.get('/categories/$id');
    return Category.fromJson(response.data['data']);
  }
}