import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart'; // Ensure you have this
import 'package:tusfind_frontend/features/item_found/screen/found_form_screen.dart';

// ivan
class FoundDetailScreen extends StatefulWidget {
  final ItemFoundRepository repo;
  final int id;

  const FoundDetailScreen({
    super.key,
    required this.repo,
    required this.id,
  });

  @override
  State<FoundDetailScreen> createState() => _FoundDetailScreenState();
}

class _FoundDetailScreenState extends State<FoundDetailScreen> {
  late Future<ItemFound> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getFoundItemDetail(widget.id);
    });
  }

  Future<void> _edit(ItemFound item) async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoundFormScreen(
          repo: widget.repo,
          categoryRepo: CategoryRepository(widget.repo.api),
          itemRepo: ItemRepository(widget.repo.api),
          existing: item,
        ),
      ),
    );

    if (refresh == true) _refresh();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'pending':
        return Colors.orange;
      case 'claimed':
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Header
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(
        title: 'Detail Penemuan',
        showBackButton: true,
        icon: Icons.find_in_page_rounded,
        // actions: [
        // ],
      ),
      body: FutureBuilder<ItemFound>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Item not found'));
          }

          final item = snapshot.data!;
          final statusColor = _getStatusColor(item.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: statusColor),
                          const SizedBox(width: 8),
                          Text(
                            item.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                      onPressed: () => _edit(item),
                      tooltip: "Edit Laporan",
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  item.item?.name ?? 'Unknown Item',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.category_outlined,
                        label: "Kategori",
                        value: item.category?.name ?? '-',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.location_on_outlined,
                        label: "Lokasi Ditemukan",
                        value: item.foundLocation ?? '-',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Deskripsi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    item.description ?? 'Tidak ada deskripsi tambahan.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // if (item.createdAt != null) ...[
                //   Row(
                //     children: [
                //       Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                //       const SizedBox(width: 6),
                //       Text(
                //         "Dilaporkan pada: ${item.createdAt.toString().split('.')[0]}",
                //         style: TextStyle(color: Colors.grey[400], fontSize: 12),
                //       ),
                //     ],
                //   ),
                // ],

                // Bottom Spacing
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),

    );
  }
}