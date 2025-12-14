import 'package:tusfind_frontend/core/models/item_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

// ivan
class ItemRepository {
  final ApiService api;

  ItemRepository(this.api);

  Future<List<Item>> getItems() async {
    final response = await api.get('/items');

    final List data = response.data['data'];
    return data.map((e) => Item.fromJson(e)).toList();
  }

  Future<Item> getItemDetail(int id) async {
    final response = await api.get('/items/$id');
    return Item.fromJson(response.data['data']);
  }

  Future<Item> createItem({
    required String name,
    int? categoryId,
    String? brand,
    String? color,
  }) async {
    final response = await api.post(
      '/items',
      {
        'name': name,
        'category_id': categoryId,
        'brand': brand,
        'color': color,
      },
    );

    return Item.fromJson(response.data['data']);
  }
}