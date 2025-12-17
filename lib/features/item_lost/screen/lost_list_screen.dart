import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart'; // Ensure this points to the new card
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
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getLostItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 1. Background color makes cards pop
      appBar: AppAppBar(
          icon: Icons.report_gmailerrorred,
          title: 'Laporan Barang Hilang'
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

          final items = snapshot.data!;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada laporan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]
                    ),
                  ),
                  Text(
                    'Laporan barang hilang akan muncul disini',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 80),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final lost = items[index];

                return ItemReportCard(
                  title: lost.item?.name ?? 'Unknown Item',
                  location: lost.lostLocation ?? '-',
                  category: lost.category?.name ?? 'Umum',
                  date: "Baru saja",
                  status: lost.status,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LostDetailScreen(repo: widget.repo, id: lost.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 130),
        child: FloatingActionButton.extended(
          backgroundColor: AppColor.primary,
          elevation: 4,
          onPressed: () async {
            final created = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LostFormScreen(repo: widget.repo),
              ),
            );

            if (created == true) {
              _refresh();
            }
          },
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text("Buat Laporan", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}