// ariana

class AdminDashboard {
  final int totalReports;
  final int lostCount;
  final int foundCount;
  final int resolvedCount;
  final List<AdminRecentActivity> recentActivities;

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
          .map((e) => AdminRecentActivity.fromJson(e))
          .toList(),
    );
  }
}

class AdminRecentActivity {
  final int id;
  final String name;
  final String type; // lost / found
  final String? brand;
  final String? color;

  AdminRecentActivity({
    required this.id,
    required this.name,
    required this.type,
    this.brand,
    this.color,
  });

  factory AdminRecentActivity.fromJson(Map<String, dynamic> json) {
    return AdminRecentActivity(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      brand: json['brand'],
      color: json['color'],
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