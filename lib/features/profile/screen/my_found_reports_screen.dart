import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_detail_screen.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_form_screen.dart'; // Import Form
import 'package:tusfind_frontend/core/repositories/category_repository.dart'; // Needed for Form
import 'package:tusfind_frontend/core/repositories/item_repository.dart'; // Needed for Form

// ivan
class MyFoundReportsScreen extends StatefulWidget {
  final ItemFoundRepository repo;

  const MyFoundReportsScreen({super.key, required this.repo});

  @override
  State<MyFoundReportsScreen> createState() => _MyFoundReportsScreenState();
}

class _MyFoundReportsScreenState extends State<MyFoundReportsScreen> {
  late Future<List<ItemFound>> _future;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getMyFoundItems(status: _selectedStatus);
    });
  }

  void _onFilterChanged(String? status) {
    setState(() {
      _selectedStatus = (_selectedStatus == status) ? null : status;
    });
    _refresh();
  }

  void _showActionMenu(ItemFound item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "Kelola Laporan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Divider(),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.blue.shade700,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    "Edit Laporan",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Perbarui detail informasi barang",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleEdit(item);
                  },
                ),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade700,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    "Hapus Laporan",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                  subtitle: Text(
                    "Tindakan ini permanen",
                    style: TextStyle(color: Colors.red[300]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEdit(ItemFound item) async {
    final api = widget.repo.api;

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoundFormScreen(
          repo: widget.repo,
          categoryRepo: CategoryRepository(api),
          itemRepo: ItemRepository(api),
          existing: item,
        ),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "Laporan berhasil diperbarui",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(ItemFound item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text("Hapus Laporan?"),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin menghapus laporan ini? Data yang dihapus tidak dapat dikembalikan.",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text("Batal", style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Ya, Hapus",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.repo.deleteFoundItem(item.id);
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Laporan dihapus")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppAppBar(
        title: "Laporan Penemuan Saya",
        showBackButton: true,
        icon: Icons.history_edu,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Semua", null),
                  const SizedBox(width: 8),
                  _buildFilterChip("Pending", "pending"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Claimed", "claimed"),
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ItemFound>>(
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
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ada data",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
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
                        location: item.foundLocation ?? '-',
                        status: item.status,
                        category: item.category?.name ?? 'Umum',
                        date: "Baru saja",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoundDetailScreen(
                                repo: widget.repo,
                                id: item.id,
                              ),
                            ),
                          );
                        },
                        onLongPress: () => _showActionMenu(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? statusValue) {
    final isSelected = _selectedStatus == statusValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(statusValue),
      backgroundColor: Colors.grey[100],
      selectedColor: AppColor.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColor.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColor.primary : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
    );
  }
}
