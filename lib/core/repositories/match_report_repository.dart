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
