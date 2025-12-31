import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart'; // Ensure this imports the updated card
import 'package:tusfind_frontend/features/item_found/screen/found_detail_screen.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_form_screen.dart';

// ivan
class FoundListScreen extends StatefulWidget {
  final ItemFoundRepository repo;

  const FoundListScreen({super.key, required this.repo});

  @override
  State<FoundListScreen> createState() => _FoundListScreenState();
}

class _FoundListScreenState extends State<FoundListScreen> {
  List<ItemFound> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await widget.repo.getFoundItems();
      if (mounted) {
        setState(() {
          _items = res;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(
          icon: Icons.find_in_page_rounded,
          title: "Laporan Penemuan Barang"
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.content_paste_search, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada barang ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Laporan penemuan akan muncul disini',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 80), // 3. Breathing room
          itemCount: _items.length,
          itemBuilder: (_, index) {
            final item = _items[index];
            return ItemReportCard(
              title: item.item?.name ?? 'Unknown Item',
              location: item.foundLocation ?? '-',
              status: item.status,
              category: item.category?.name ?? 'Umum',
              date: "Baru saja",
              onTap: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoundDetailScreen(
                        repo: widget.repo,
                        id: item.id
                    ),
                  ),
                );
                if (refresh == true) _load();
              },
            );
          },
        ),
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
                builder: (_) => FoundFormScreen(
                  repo: widget.repo,
                  categoryRepo: CategoryRepository(widget.repo.api),
                  itemRepo: ItemRepository(widget.repo.api),
                ),
              ),
            );

            if (created == true) {
              _load();
            }
          },
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text("Lapor Penemuan", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}