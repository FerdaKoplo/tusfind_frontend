import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_image_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';

// ivan
class ItemFound {
  final int id;
  final int userId;
  final int categoryId;
  final int? itemId;
  final String status;
  final String? foundDate;
  final String? foundLocation;
  final String? description;
  final Category? category;
  final Item? item;
  final String? customItemName;
  final List<ItemImage> images;

  ItemFound({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.itemId,
    required this.status,
    this.foundDate,
    this.foundLocation,
    this.description,
    this.category,
    this.item,
    this.customItemName,
    required this.images,
  });

  factory ItemFound.fromJson(Map<String, dynamic> json) {
    return ItemFound(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      itemId: json['item_id'],
      status: json['status'],
      foundDate: json['found_date'],
      foundLocation: json['found_location'],
      description: json['description'],
      customItemName: json['custom_item_name'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => ItemImage.fromJson(e)).toList()
          : [],
    );
  }
}
