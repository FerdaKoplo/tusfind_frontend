import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_detail_screen.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_form_screen.dart';

class LostListScreen extends StatefulWidget {
  final ItemLostRepository repo;

  const LostListScreen({super.key, required this.repo});

  @override
  State<LostListScreen> createState() => _LostListScreenState();
}

class _LostListScreenState extends State<LostListScreen> {
  late Future<List<ItemLost>> _future;

  List<ItemLost> allItems = [];
  List<ItemLost> filteredItems = [];

  String selectedCategory = 'Semua';
  String selectedSort = 'Terbaru';

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

  void applyFilterAndSort() {
    List<ItemLost> temp = [...allItems];

    // FILTER KATEGORI
    if (selectedCategory != 'Semua') {
      temp = temp
          .where((item) => item.category?.name == selectedCategory)
          .toList();
    }

    // SORT TANGGAL
    if (selectedSort == 'Terbaru') {
      temp.sort((a, b) => b.id.compareTo(a.id));
    } else {
      temp.sort((a, b) => a.id.compareTo(b.id));
    }

    setState(() {
      filteredItems = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(
        icon: Icons.report_gmailerrorred,
        title: 'Laporan Barang Hilang',
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

          // --- BAGIAN YANG DIPERBAIKI (MULAI) ---

          // 1. Ambil data mentah dari API
          allItems = snapshot.data!;

          // 2. Tentukan list mana yang mau ditampilkan menggunakan variabel LOKAL
          // Jangan panggil applyFilterAndSort() atau setState() di sini!
          List<ItemLost> displayList = filteredItems;

          // Jika filteredItems masih kosong dan kita sedang memilih 'Semua' (artinya ini load pertama),
          // Maka kita isi displayList secara manual tanpa setState.
          if (displayList.isEmpty && selectedCategory == 'Semua') {
            displayList = List.from(allItems);
            // Terapkan default sort (Terbaru) secara lokal
            displayList.sort((a, b) => b.id.compareTo(a.id));
          }

          // --- BAGIAN YANG DIPERBAIKI (SELESAI) ---

          // Cek apakah list yang mau ditampilkan kosong
          if (displayList.isEmpty) {
            // Ubah filteredItems jadi displayList
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada laporan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
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
            child: Column(
              children: [
                // FILTER BAR
                // Padding(
                //   padding: const EdgeInsets.all(12),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: DropdownButtonFormField<String>(
                //           value: selectedCategory,
                //           items:
                //               const [
                //                     'Semua',
                //                     'Elektronik',
                //                     'Dokumen',
                //                     'Aksesoris',
                //                   ]
                //                   .map(
                //                     (e) => DropdownMenuItem(
                //                       value: e,
                //                       child: Text(e),
                //                     ),
                //                   )
                //                   .toList(),
                //           onChanged: (value) {
                //             // setState aman dipanggil di sini (karena interaksi user)
                //             selectedCategory = value!;
                //             applyFilterAndSort();
                //           },
                //           decoration: const InputDecoration(
                //             labelText: 'Kategori',
                //             border: OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: DropdownButtonFormField<String>(
                //           value: selectedSort,
                //           items: const [
                //             DropdownMenuItem(
                //               value: 'Terbaru',
                //               child: Text('Terbaru'),
                //             ),
                //             DropdownMenuItem(
                //               value: 'Terlama',
                //               child: Text('Terlama'),
                //             ),
                //           ],
                //           onChanged: (value) {
                //             // setState aman dipanggil di sini
                //             selectedSort = value!;
                //             applyFilterAndSort();
                //           },
                //           decoration: const InputDecoration(
                //             labelText: 'Urutkan',
                //             border: OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 80),
                    // Pastikan menggunakan displayList, BUKAN filteredItems
                    itemCount: displayList.length,
                    itemBuilder: (_, index) {
                      final lost = displayList[index]; // Pakai displayList

                      return ItemReportCard(
                        title: lost.item?.name ?? 'Unknown Item',
                        location: lost.lostLocation ?? '-',
                        category: lost.category?.name ?? 'Umum',
                        date: 'Laporan ke-${lost.id}',
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 130),
        child: FloatingActionButton.extended(
          backgroundColor: AppColor.primary,
          onPressed: () async {
            final created = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LostFormScreen(repo: widget.repo),
              ),
            );
            if (created == true) _refresh();
          },
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text(
            "Buat Laporan",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
