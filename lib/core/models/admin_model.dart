// ariana

class AdminDashboard {
  final int totalReports;
  final int lostCount;
  final int foundCount;
  final int resolvedCount;
  final List<AdminActivity> recentActivities;

  AdminDashboard({
    required this.totalReports,
    required this.lostCount,
    required this.foundCount,
    required this.resolvedCount,
    required this.recentActivities,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      // Backend mengirim 'totalReports', bukan 'total_reports'
      totalReports: json['totalReports'] ?? 0,
      lostCount: json['lostCount'] ?? 0,
      foundCount: json['foundCount'] ?? 0,
      resolvedCount: json['resolvedCount'] ?? 0,
      recentActivities: (json['recentActivities'] as List?)
          ?.map((item) => AdminActivity.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class AdminActivity {
  final int id;
  final String name;
  final String? brand;
  final String? color;
  final String type; // 'lost' atau 'found'
  final String createdAt;

  AdminActivity({
    required this.id,
    required this.name,
    this.brand,
    this.color,
    required this.type,
    required this.createdAt,
  });

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    return AdminActivity(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      brand: json['brand'],
      color: json['color'],
      type: json['type'] ?? 'lost',
      createdAt: json['created_at'] ?? '', // Backend mengirim 'created_at' (snake_case) di dalam map function
    );
  }
}