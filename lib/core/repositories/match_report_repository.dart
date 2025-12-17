import 'package:tusfind_frontend/core/models/match_report_model.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

class MatchRepository {
  final ApiService api;

  MatchRepository(this.api);

  Future<List<MatchReport>> getMatches() async {
    final response = await api.get('/matches');
    final List data = response.data['data'];
    return data.map((e) => MatchReport.fromJson(e)).toList();
  }

  Future<MatchReport> getMatchDetail(int id) async {
    final response = await api.get('/matches/$id');
    print("API RESPONSE FOR MATCH $id:");
    final itemLostData = response.data['data']['item_lost'];
    print("Item Lost Data: $itemLostData");

    // Check if 'item' key exists inside 'item_lost'
    if (itemLostData != null && itemLostData['item'] == null) {
      print("⚠️ CRITICAL ISSUE: The 'item' object is MISSING inside 'item_lost'.");
      print("   This is why the name shows as 'Unknown'.");
      print("   You must update your Backend Controller to include/join the 'item' table.");
    }
    return MatchReport.fromJson(response.data['data']);
  }

  Future<void> autoMatch() async {
    await api.post('/matches/auto-match', {});
  }

  Future<void> confirmMatch(int id) async {
    await api.post('/matches/$id/confirm', {});
  }

  Future<void> rejectMatch(int id) async {
    await api.post('/matches/$id/reject', {});
  }
}
