import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/profile_model.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/repositories/profile_repository.dart';
import 'package:tusfind_frontend/core/widgets/profile_stat_card.dart';
import 'package:tusfind_frontend/features/profile/screen/my_found_reports_screen.dart';
import 'package:tusfind_frontend/features/profile/screen/my_lost_report_screen.dart';

// ivan
class ProfileScreen extends StatefulWidget {
  final ProfileRepository profileRepo;
  final ItemLostRepository lostRepo;
  final ItemFoundRepository foundRepo;

  const ProfileScreen({
    super.key,
    required this.profileRepo,
    required this.lostRepo,
    required this.foundRepo,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = widget.profileRepo.getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFFF0F0F0),
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "User Name",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "student@telkomuniversity.ac.id",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -25),
              child: FutureBuilder<ProfileStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  final stats = snapshot.data;
                  return ProfileStatsCard(
                    lostCount: stats?.lostCount ?? 0,
                    foundCount: stats?.foundCount ?? 0,
                    resolvedCount: stats?.resolvedCount ?? 0,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuTile(
                    title: "Laporan Kehilangan Saya",
                    subtitle: "Cek status barang yang Anda cari",
                    icon: Icons.search_off_rounded,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyLostReportsScreen(repo: widget.lostRepo),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuTile(
                    title: "Laporan Penemuan Saya",
                    subtitle: "Barang yang Anda temukan",
                    icon: Icons.travel_explore_rounded,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyFoundReportsScreen(repo: widget.foundRepo),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuTile(
                    title: "Keluar",
                    subtitle: "Log out dari akun",
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    onTap: () {
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[300]),
      ),
    );
  }
}