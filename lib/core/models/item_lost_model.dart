import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_image_model.dart';
import 'package:tusfind_frontend/core/models/item_model.dart';

// ivan
class ItemLost {
  final int id;
  final int userId;
  final int categoryId;
  final int? itemId;
  final String? lostDate;
  final String? lostLocation;
  final String? description;
  final String status;
  final Category? category;
  final Item? item;
  final List<ItemImage> images;
  final String? customItemName;

  ItemLost({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.itemId,
    this.lostDate,
    this.lostLocation,
    this.description,
    required this.status,
    this.category,
    this.item,
    required this.images,
    this.customItemName,
  });

  factory ItemLost.fromJson(Map<String, dynamic> json) {
    return ItemLost(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      itemId: json['item_id'],
      lostDate: json['lost_date'],
      lostLocation: json['lost_location'],
      description: json['description'],
      status: json['status'],
      customItemName: json['custom_item_name'],
      category:
      json['category'] != null ? Category.fromJson(json['category']) : null,
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
      images: json['images'] != null
          ? (json['images'] as List)
          .map((e) => ItemImage.fromJson(e))
          .toList()
          : [],
    );
  }
}
