import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_detail_screen.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_form_screen.dart';

// ivan
class LostListScreen extends StatefulWidget {
  final ItemLostRepository repo;

  const LostListScreen({super.key, required this.repo});

  @override
  State<LostListScreen> createState() => _LostListScreenState();
}

class _LostListScreenState extends State<LostListScreen> {
  late Future<List<ItemLost>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repo.getLostItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Items')),
      body: FutureBuilder<List<ItemLost>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No lost items'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, index) {
              final lost = items[index];

              return ItemReportCard(
                title: lost.item?.name ?? 'Unknown Item',
                subtitle: lost.lostLocation ?? '-',
                status: lost.status,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LostDetailScreen(
                        repo: widget.repo,
                        id: lost.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LostFormScreen(repo: widget.repo),
            ),
          );

          if (created == true) {
            setState(() {
              _future = widget.repo.getLostItems();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
