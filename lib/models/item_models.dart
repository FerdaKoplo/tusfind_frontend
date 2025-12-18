class Item {
  final int id;
  final String title;
  final String category;
  final String location;
  final String date;
  final String status;

  Item({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.status,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      date: json['date'],
      status: json['status'],
    );
  }
}
