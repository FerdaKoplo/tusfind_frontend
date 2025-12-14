
// ivan
class ItemImage {
  final int id;
  final String imagePath;
  final int itemId;
  final int? itemLostId;
  final int? itemFoundId;

  ItemImage({
    required this.id,
    required this.imagePath,
    required this.itemId,
    this.itemLostId,
    this.itemFoundId,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'],
      imagePath: json['image_path'],
      itemId: json['item_id'],
      itemLostId: json['item_lost_id'],
      itemFoundId: json['item_found_id'],
    );
  }
}
