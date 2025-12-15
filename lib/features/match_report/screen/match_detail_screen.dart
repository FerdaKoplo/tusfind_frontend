import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/match_report_model.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';

class MatchDetailScreen extends StatelessWidget {
  final MatchRepository repo;
  final int id;

  const MatchDetailScreen({
    super.key,
    required this.repo,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Detail')),
      body: FutureBuilder<MatchReport>(
        future: repo.getMatchDetail(id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final match = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lost Item: ${match.itemLost.item?.name ?? '-'}'),
                Text('Found Item: ${match.itemFound.item?.name ?? '-'}'),
                const SizedBox(height: 8),
                Text('Match Score: ${match.matchScore}%'),
                Text('Status: ${match.status}'),
                const Spacer(),

                if (match.status == 'pending') ...[
                  ElevatedButton(
                    onPressed: () async {
                      await repo.confirmMatch(match.id);
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm Match'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await repo.rejectMatch(match.id);
                      Navigator.pop(context);
                    },
                    child: const Text('Reject'),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
