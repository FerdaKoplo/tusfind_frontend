import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

class ItemLostRepository {
  final ApiService api;

  ItemLostRepository(this.api);

  Future<List<ItemLost>> getLostItems() async {
    final response = await api.get('/lost-items');

    final List data = response.data['data'];
    return data.map((e) => ItemLost.fromJson(e)).toList();
  }

  Future<ItemLost> getLostItemDetail(int id) async {
    final response = await api.get('/lost-items/$id');
    return ItemLost.fromJson(response.data['data']);
  }



  Future<ItemLost> createLostItem({
    required int categoryId,
    int? itemId,
    String? customItemName,
    String? lostLocation,
    String? description,
    List<File>? images,
  }) async {
    Map<String, dynamic> data = {
      'category_id': categoryId,
      if (itemId != null) 'item_id': itemId,
      if (customItemName != null) 'custom_item_name': customItemName,
      'lost_location': lostLocation,
      'description': description,
    };

    FormData formData = FormData.fromMap(data);

    if (images != null) {
      for (var file in images) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }
    }

    final response = await api.post('/lost-items', formData);
    return ItemLost.fromJson(response.data['data']);
  }

  Future<ItemLost> updateLostItem(
      int id, {
        int? categoryId,
        int? itemId,
        String? customItemName,
        String? lostDate,
        String? lostLocation,
        String? description,
      }) async {
    final response = await api.put('/lost-items/$id', {
      'category_id': categoryId,
      'item_id': itemId,
      'custom_item_name': customItemName,
      'lost_date': lostDate,
      'lost_location': lostLocation,
      'description': description,
    });

    print("Update Item Lost Data: $response");

    return ItemLost.fromJson(response.data['data']);
  }

  Future<void> deleteLostItem(int id) async {
    await api.delete('/lost-items/$id');
  }

  Future<List<ItemLost>> getMyLostItems({String? status, String? search}) async {
    try {
      final response = await api.get(
        '/profile/lost-items',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null) 'search': search,
        },
      );

      final List data = response.data['data'];
      return data.map((e) => ItemLost.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

}
