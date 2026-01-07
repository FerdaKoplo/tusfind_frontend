import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/item_found_model.dart';
import 'package:tusfind_frontend/core/repositories/category_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_form_screen.dart';

class FoundDetailScreen extends StatefulWidget {
  final ItemFoundRepository repo;
  final int id;

  const FoundDetailScreen({super.key, required this.repo, required this.id});

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

  // void _refresh() => setState(() => _future = widget.repo.getFoundItemDetail(widget.id));

  void _refresh() {
    final newFuture = widget.repo.getFoundItemDetail(widget.id);

    setState(() {
      _future = newFuture;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'claimed':
      case 'resolved': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildImageSection(ItemFound item) {
    if (item.images.isEmpty) {
      return Container(
        height: 250, width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
      );
    }

    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: item.images.length,
        itemBuilder: (context, index) {
          final imageUrl = widget.repo.api.storageUrl + item.images[index].imagePath;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.primary, size: 20),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(title: 'Detail Penemuan', showBackButton: true, icon: Icons.find_in_page_rounded),
      body: FutureBuilder<ItemFound>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          final item = snapshot.data!;
          final statusColor = _getStatusColor(item.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(item.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    // IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () async {
                    //   final refresh = await Navigator.push(context, MaterialPageRoute(builder: (_) => FoundFormScreen(repo: widget.repo, categoryRepo: CategoryRepository(widget.repo.api), itemRepo: ItemRepository(widget.repo.api), existing: item)));
                    //   if (refresh == true) _refresh();
                    // }),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.item?.name ?? item.customItemName ?? 'Unknown Item', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildImageSection(item),


                Row(
                  children: [
                    Expanded(child: _buildDetailCard(icon: Icons.category_outlined, label: "Kategori", value: item.category?.name ?? '-')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDetailCard(icon: Icons.location_on_outlined, label: "Lokasi", value: item.foundLocation ?? '-')),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    item.description ?? 'No description provided.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
                // Text(item.description ?? 'Tidak ada deskripsi.'),
              ],
            ),
          );
        },
      ),
    );
  }
}