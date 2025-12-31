import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/item_report_card.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_detail_screen.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_form_screen.dart';
import 'package:tusfind_frontend/core/widgets/action_modal.dart';
import 'package:tusfind_frontend/core/widgets/confirmation_dialog.dart';

class MyLostReportsScreen extends StatefulWidget {
  final ItemLostRepository repo;

  const MyLostReportsScreen({super.key, required this.repo});

  @override
  State<MyLostReportsScreen> createState() => _MyLostReportsScreenState();
}

class _MyLostReportsScreenState extends State<MyLostReportsScreen> {
  late Future<List<ItemLost>> _future;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getMyLostItems(status: _selectedStatus);
    });
  }

  void _onFilterChanged(String? status) {
    setState(() {
      _selectedStatus = (_selectedStatus == status) ? null : status;
    });
    _refresh();
  }

  void _showActionMenu(ItemLost item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ActionModal(
          title: item.item?.name ?? "Item Unknown",
          children: [
            ActionModalOption(
              icon: Icons.edit_rounded,
              color: Colors.blue,
              title: "Edit Laporan",
              subtitle: "Perbarui informasi barang",
              onTap: () {
                Navigator.pop(context);
                _handleEdit(item);
              },
            ),
            ActionModalOption(
              icon: Icons.delete_outline_rounded,
              color: Colors.red,
              title: "Hapus Laporan",
              subtitle: "Data akan dihapus permanen",
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

  Future<void> _handleEdit(ItemLost item) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LostFormScreen(repo: widget.repo, existing: item),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Laporan berhasil diperbarui"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(ItemLost item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: "Hapus Laporan?",
        subtitle:
            "Apakah Anda yakin ingin menghapus laporan ini? Tindakan ini tidak dapat dibatalkan.",
        confirmLabel: "Ya, Hapus",
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      try {
        await widget.repo.deleteLostItem(item.id);
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Laporan telah dihapus")),
          );
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
        title: "Laporan Kehilangan Saya",
        showBackButton: true,
        icon: Icons.history,
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
                  _buildFilterChip("Matched", "matched"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Resolved", "resolved"),
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ItemLost>>(
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
                          Icons.folder_off_outlined,
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
                        location: item.lostLocation ?? '-',
                        status: item.status,
                        category: item.category?.name ?? 'Umum',
                        date: "Baru saja",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LostDetailScreen(
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
