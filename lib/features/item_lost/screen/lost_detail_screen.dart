import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/item_lost_model.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';

// ivan
class LostDetailScreen extends StatelessWidget {
  final ItemLostRepository repo;
  final int id;

  const LostDetailScreen({super.key, required this.repo, required this.id});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'matched':
        return Colors.blue;
      case 'resolved':
      case 'claimed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _detailCard({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(ItemLost item) {
    if (item.images.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text("No images available", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: item.images.length,
        itemBuilder: (context, index) {
          final imageUrl = repo.api.storageUrl + item.images[index].imagePath;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(
        title: "Detail Laporan",
        showBackButton: true,
        icon: Icons.report_gmailerrorred,
      ),
      body: FutureBuilder<ItemLost>(
        future: repo.getLostItemDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Item not found"));
          }

          final item = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusBadge(item.status),
                    const SizedBox(height: 12),
                    Text(
                      item.item?.name ?? 'Unknown Item',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),


                _buildImageSection(item),


                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _detailCard(
                        context: context,
                        icon: Icons.category_outlined,
                        label: "Category",
                        value: item.category?.name ?? '-',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _detailCard(
                        context: context,
                        icon: Icons.location_on_outlined,
                        label: "Last Location",
                        value: item.lostLocation ?? '-',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
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

                const SizedBox(height: 40),
              ],


            ),
          );
        },
      ),
    );
  }


}