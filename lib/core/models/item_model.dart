import 'package:tusfind_frontend/core/models/category_model.dart';
import 'package:tusfind_frontend/core/models/item_image_model.dart';

// ivan
class Item {
  final int id;
  final String name;
  final String? brand;
  final String? color;
  final Category? category;
  final List<ItemImage> images;

  Item({
    required this.id,
    required this.name,
    this.brand,
    this.color,
    this.category,
    required this.images,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      color: json['color'],
      category:
      json['category'] != null ? Category.fromJson(json['category']) : null,
      images: json['images'] != null
          ? (json['images'] as List)
          .map((e) => ItemImage.fromJson(e))
          .toList()
          : [],
    );
  }
}
