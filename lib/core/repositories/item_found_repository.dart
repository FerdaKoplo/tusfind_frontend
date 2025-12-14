import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

// ivan
class ItemFoundRepository {
  final ApiService api;

  ItemFoundRepository(this.api);

  Future<List<ItemFound>> getFoundItems() async {
    final response = await api.get('/item-founds');

    final List data = response.data['data'];
    return data.map((e) => ItemFound.fromJson(e)).toList();
  }

  Future<ItemFound> getFoundItemDetail(int id) async {
    final response = await api.get('/item-founds/$id');
    return ItemFound.fromJson(response.data['data']);
  }

  Future<ItemFound> createFoundItem({
    required int categoryId,
    required int itemId,
    String? foundDate,
    String? foundLocation,
    String? description,
  }) async {
    final response = await api.post(
      '/item-founds',
      {
        'category_id': categoryId,
        'item_id': itemId,
        'found_date': foundDate,
        'found_location': foundLocation,
        'description': description,
      },
    );

    return ItemFound.fromJson(response.data['data']);
  }

  Future<ItemFound> updateFoundItem(
      int id, {
        int? categoryId,
        int? itemId,
        String? foundDate,
        String? foundLocation,
        String? description,
      }) async {
    final response = await api.post(
      '/item-founds/$id',
      {
        '_method': 'PUT',
        if (categoryId != null) 'category_id': categoryId,
        if (itemId != null) 'item_id': itemId,
        'found_date': foundDate,
        'found_location': foundLocation,
        'description': description,
      },
    );

    return ItemFound.fromJson(response.data['data']);
  }

  Future<void> deleteFoundItem(int id) async {
    await api.post('/item-founds/$id', {
      '_method': 'DELETE',
    });
  }
}