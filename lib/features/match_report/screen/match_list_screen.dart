import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/match_report_model.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';
import 'package:tusfind_frontend/core/widgets/match_report_card.dart';
import 'package:tusfind_frontend/features/match_report/screen/match_detail_screen.dart';

class MatchListScreen extends StatefulWidget {
  final MatchRepository repo;

  const MatchListScreen({super.key, required this.repo});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  late Future<List<MatchReport>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repo.getMatches();
  }

  Future<void> _runAutoMatch() async {
    await widget.repo.autoMatch();
    setState(() {
      _future = widget.repo.getMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryLight,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Icon(Icons.link, color: Colors.white, size: 25),
            SizedBox(width: 10),
            Text(
              'Matches',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      body: Container(
        color: AppColor.background,
        child: FutureBuilder<List<MatchReport>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final matches = snapshot.data!;
            if (matches.isEmpty) {
              return const Center(child: Text('No matches yet'));
            }

            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];

                return MatchReportCard(
                  lostItem: match.itemLost.item?.name ?? '-',
                  foundItem: match.itemFound.item?.name ?? '-',
                  score: match.matchScore,
                  status: match.status,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MatchDetailScreen(repo: widget.repo, id: match.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryLight,
        onPressed: _runAutoMatch,
        tooltip: 'Run Auto Match',
        child: const Icon(Icons.auto_fix_high, color: Colors.white),
      ),
    );
  }
}
