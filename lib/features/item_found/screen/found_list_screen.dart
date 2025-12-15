import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart';
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
      setState(() {
        _items = res;
        _loading = false;
      });
    } catch (e) {
      _loading = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryLight,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10,
          children: const [
            Icon(Icons.find_in_page, color: Colors.white, size: 25),
            Text(
              'Laporan Penemuan Barang',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ), // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () async {
        //       final refresh = await Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) => FoundFormScreen(
        //             repo: widget.repo,
        //             categoryRepo: CategoryRepository(widget.repo.api),
        //             itemRepo: ItemRepository(widget.repo.api),
        //           ),
        //         ),
        //       );
        //       if (refresh == true) _load();
        //     },
        //   ),
        // ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('No found items yet'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final item = _items[index];
                return ItemReportCard(
                  title: item.item?.name ?? '-',
                  subtitle: item.foundLocation ?? '-',
                  status: item.status,
                  onTap: () async {
                    final refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FoundDetailScreen(repo: widget.repo, id: item.id),
                      ),
                    );
                    if (refresh == true) _load();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryLight,
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
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
