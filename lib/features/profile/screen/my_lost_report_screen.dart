import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_detail_screen.dart';


// ivan
class MyLostReportsScreen extends StatefulWidget {
  final ItemLostRepository repo;

  const MyLostReportsScreen({super.key, required this.repo});

  @override
  State<MyLostReportsScreen> createState() => _MyLostReportsScreenState();
}

class _MyLostReportsScreenState extends State<MyLostReportsScreen> {
  late Future<List<ItemLost>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getMyLostItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppAppBar(
        title: "Laporan Kehilangan Saya",
        showBackButton: true,
        icon: Icons.history,
      ),
      body: FutureBuilder<List<ItemLost>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada riwayat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Anda belum pernah melaporkan kehilangan.",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return ItemReportCard(
                  title: item.item?.name ?? 'Unknown',
                  location: item.lostLocation ?? '-',
                  status: item.status,
                  category: item.category?.name ?? 'Umum',
                  date: "Baru saja",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LostDetailScreen(repo: widget.repo, id: item.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}