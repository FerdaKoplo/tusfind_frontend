// ariana

// ariana_tambah untuk admin
import 'package:tusfind_frontend/core/models/item_model.dart';

class AdminDashboard {
  final int totalReports;
  final int lostCount;
  final int foundCount;
  final int resolvedCount;
  final List<Item> recentActivities;

  AdminDashboard({
    required this.totalReports,
    required this.lostCount,
    required this.foundCount,
    required this.resolvedCount,
    required this.recentActivities,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalReports: json['total_reports'] ?? 0,
      lostCount: json['lost_items'] ?? 0,
      foundCount: json['found_items'] ?? 0,
      resolvedCount: json['resolved_items'] ?? 0,
      recentActivities: (json['recent_activities'] as List? ?? [])
          .map((e) => Item.fromJson(e))
          .toList(),
    );
  }
}

// ini untuk struktur data yang ada pada admincontroller

// {
//   "status": "success",
//   "data": {
//     "total_reports": 100,
//     "lost_items": 40,
//     "found_items": 60,
//     "resolved_items": 30,
//     "recent_activities": [
//       { "id": 1, "name": "Kunci", "type": "lost", "brand": "Honda", "color": "Black" }
//     ]
//   }
// }