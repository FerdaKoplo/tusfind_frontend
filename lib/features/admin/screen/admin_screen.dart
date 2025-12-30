import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';
import 'package:tusfind_frontend/core/repositories/admin_repository.dart';
import 'package:tusfind_frontend/core/models/admin_model.dart';


class AdminScreen extends StatefulWidget {
  final String token;
  const AdminScreen({super.key, required this.token});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late AdminRepository _repository;
  late Future<AdminDashboard> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService(token: widget.token);
    _repository = AdminRepository(apiService);
    _dashboardFuture = _repository.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<AdminDashboard>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final stats = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() { _dashboardFuture = _repository.getDashboardStats(); });
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Statistik Barang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildCard("Total", stats.totalReports.toString(), Colors.blue, CupertinoIcons.archivebox),
                      _buildCard("Hilang", stats.lostCount.toString(), Colors.red, CupertinoIcons.exclamationmark_triangle),
                      _buildCard("Ditemukan", stats.foundCount.toString(), Colors.green, CupertinoIcons.search),
                      _buildCard("Selesai", stats.resolvedCount.toString(), Colors.indigo, CupertinoIcons.check_mark_circled),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text("Laporan Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.recentActivities.length,
                    itemBuilder: (context, index) {
                      final item = stats.recentActivities[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.type == 'lost' ? Colors.red[50] : Colors.green[50],
                            child: Icon(
                              item.type == 'lost' ? CupertinoIcons.search : CupertinoIcons.archivebox_fill,                              color: item.type == 'lost' ? Colors.red : Colors.green,
                              size: 20,
                            ),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("${item.brand ?? 'No Brand'} • ${item.color ?? ''}"),
                          trailing: const Icon(CupertinoIcons.chevron_forward, size: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}