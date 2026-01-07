import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_detail_screen.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_form_screen.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/action_modal.dart';
import 'package:tusfind_frontend/core/widgets/confirmation_dialog.dart';

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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ActionModal(
          title: item.item?.name ?? "Item Unknown",
          subtitle: "Laporan #${item.id}",
          children: [
            ActionModalOption(
              icon: Icons.edit_rounded,
              color: Colors.blue,
              title: "Edit Laporan",
              subtitle: "Perbarui detail informasi barang",
              onTap: () {
                Navigator.pop(context);
                _handleEdit(item);
              },
            ),
            ActionModalOption(
              icon: Icons.delete_outline_rounded,
              color: Colors.red,
              title: "Hapus Laporan",
              subtitle: "Tindakan ini permanen",
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item);
              },
            ),
          ],
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
      builder: (context) => const ConfirmationDialog(
        title: "Hapus Laporan?",
        subtitle: "Apakah Anda yakin ingin menghapus laporan ini? Data yang dihapus tidak dapat dikembalikan.",
        confirmLabel: "Ya, Hapus",
        isDestructive: true,
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