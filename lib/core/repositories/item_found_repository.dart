import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

// ivan
class ItemFoundRepository {
  final ApiService api;

  ItemFoundRepository(this.api);

  Future<List<ItemFound>> getFoundItems() async {
    final response = await api.get('/found-items');
    final List data = response.data['data'];
    return data.map((e) => ItemFound.fromJson(e)).toList();
  }

  Future<ItemFound> getFoundItemDetail(int id) async {
    final response = await api.get('/found-items/$id');
    return ItemFound.fromJson(response.data['data']);
  }

  Future<ItemFound> createFoundItem({
    required int categoryId,
    int? itemId,
    String? customItemName,
    String? foundDate,
    String? foundLocation,
    String? description,
    List<File>? images,
  }) async {
    FormData formData = FormData.fromMap({
      'category_id': categoryId,
      if (itemId != null) 'item_id': itemId,
      if (customItemName != null) 'custom_item_name': customItemName,
      'found_location': foundLocation,
      'description': description,
      'status': 'pending',
    });

    if (images != null) {
      for (var file in images) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    }

    final response = await api.post('/found-items', formData);
    return ItemFound.fromJson(response.data['data']);
  }

  Future<ItemFound> updateFoundItem(
    int id, {
    int? categoryId,
    int? itemId,
    String? customItemName,
    String? foundDate,
    String? foundLocation,
    String? description,
  }) async {
    final response = await api.put('/found-items/$id', {
      if (categoryId != null) 'category_id': categoryId,
      if (itemId != null) 'item_id': itemId,
      if (customItemName != null) 'custom_item_name': customItemName,
      'found_date': foundDate,
      'found_location': foundLocation,
      'description': description,
    });

    return ItemFound.fromJson(response.data['data']);
  }

  Future<void> deleteFoundItem(int id) async {
    await api.delete('/found-items/$id');
  }

  Future<List<ItemFound>> getMyFoundItems({
    String? status,
    String? search,
  }) async {
    try {
      final response = await api.get(
        '/profile/found-items',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null) 'search': search,
        },
      );

      final List data = response.data['data'];
      return data.map((e) => ItemFound.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
