class ProfileStats {
  final int lostCount;
  final int foundCount;
  final int resolvedCount;

  ProfileStats({
    required this.lostCount,
    required this.foundCount,
    required this.resolvedCount,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      lostCount: json['lost_count'] ?? 0,
      foundCount: json['found_count'] ?? 0,
      resolvedCount: json['resolved_count'] ?? 0,
    );
  }
}