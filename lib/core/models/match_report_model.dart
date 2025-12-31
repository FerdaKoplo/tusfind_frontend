import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';

// ivan
class MatchReport {
  final int id;
  final int matchScore;
  final String status;
  final ItemLost itemLost;
  final ItemFound itemFound;

  MatchReport({
    required this.id,
    required this.matchScore,
    required this.status,
    required this.itemLost,
    required this.itemFound,
  });

  factory MatchReport.fromJson(Map<String, dynamic> json) {
    return MatchReport(
      id: json['id'],
      matchScore: json['match_score'],
      status: json['status'],
      itemLost: ItemLost.fromJson(json['item_lost']),
      itemFound: ItemFound.fromJson(json['item_found']),
    );
  }
}