import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';

// ivan
class LostDetailScreen extends StatelessWidget {
  final ItemLostRepository repo;
  final int id;

  const LostDetailScreen({
    super.key,
    required this.repo,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Detail')),
      body: FutureBuilder<ItemLost>(
        future: repo.getLostItemDetail(id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.item?.name ?? 'Unknown Item' ,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Category: ${item.category?.name ?? 'Unknown Item'}'),
                Text('Location: ${item.lostLocation ?? '-'}'),
                Text('Status: ${item.status}'),
                const SizedBox(height: 16),
                Text(item.description ?? '-'),
              ],
            ),
          );
        },
      ),
    );
  }
}
