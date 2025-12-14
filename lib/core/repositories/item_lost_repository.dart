import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

// ivan
class ItemLostRepository {
  final ApiService api;

  ItemLostRepository(this.api);

  Future<List<ItemLost>> getLostItems() async {
    final response = await api.get('/item-losts');

    final List data = response.data['data'];
    return data.map((e) => ItemLost.fromJson(e)).toList();
  }

  Future<ItemLost> getLostItemDetail(int id) async {
    final response = await api.get('/item-losts/$id');
    return ItemLost.fromJson(response.data['data']);
  }

  Future<ItemLost> createLostItem({
    required int categoryId,
    required int itemId,
    String? lostDate,
    String? lostLocation,
    String? description,
  }) async {
    final response = await api.post(
      '/item-losts',
      {
        'category_id': categoryId,
        'item_id': itemId,
        'lost_date': lostDate,
        'lost_location': lostLocation,
        'description': description,
      },
    );

    return ItemLost.fromJson(response.data['data']);
  }

  Future<ItemLost> updateLostItem(
      int id, {
        int? categoryId,
        int? itemId,
        String? lostDate,
        String? lostLocation,
        String? description,
      }) async {
    final response = await api.post(
      '/item-losts/$id',
      {
        '_method': 'PUT',
        if (categoryId != null) 'category_id': categoryId,
        if (itemId != null) 'item_id': itemId,
        'lost_date': lostDate,
        'lost_location': lostLocation,
        'description': description,
      },
    );

    return ItemLost.fromJson(response.data['data']);
  }

  Future<void> deleteLostItem(int id) async {
    await api.post('/item-losts/$id', {
      '_method': 'DELETE',
    });
  }
}