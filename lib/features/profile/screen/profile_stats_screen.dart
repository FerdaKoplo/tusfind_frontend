import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/profile_model.dart';
import 'package:tusfind_frontend/core/models/user_model.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';
import 'package:tusfind_frontend/core/repositories/profile_repository.dart';
import 'package:tusfind_frontend/core/services/auth_service.dart'; // Import AuthService
import 'package:tusfind_frontend/core/utils/string_utils.dart';
import 'package:tusfind_frontend/core/widgets/confirmation_dialog.dart';
import 'package:tusfind_frontend/core/widgets/profile_stat_card.dart';
import 'package:tusfind_frontend/features/auth/screen/login_screen.dart'; // Import your LoginPage
import 'package:tusfind_frontend/features/profile/screen/my_found_reports_screen.dart';
import 'package:tusfind_frontend/features/profile/screen/my_lost_report_screen.dart';
import 'package:tusfind_frontend/features/profile/screen/my_matches_reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileRepository profileRepo;
  final ItemLostRepository lostRepo;
  final ItemFoundRepository foundRepo;
  final MatchRepository matchRepo;

  const ProfileScreen({
    super.key,
    required this.profileRepo,
    required this.lostRepo,
    required this.foundRepo,
    required this.matchRepo,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileStats> _statsFuture;
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _statsFuture = widget.profileRepo.getStats();
      _userFuture = widget.profileRepo.getUser();
    });
  }

  void _handleLogout() async {

    bool? confirm = await showDialog(
        context: context,
        builder: (context) => const ConfirmationDialog(
          title: "Logout?",
          subtitle:
          "Apakah anda yakin ingin keluar?.",
          confirmLabel: "Keluar",
          isDestructive: true,
        )
    );

    if (confirm != true) return;

    await AuthService.logout();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container( width: double.infinity,
                padding: const EdgeInsets.only(top: 80, bottom: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: FutureBuilder<User>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    String displayName = "Loading...";
                    String displayEmail = "...";
                    Widget avatarChild = const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    );

                    if (snapshot.hasData) {
                      displayName = snapshot.data!.name;
                      displayEmail = snapshot.data!.email;

                      avatarChild = Text(
                        StringUtils.getInitials(displayName),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      displayName = "User";
                      displayEmail = "Tap to retry";
                    }

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color(0xFFF0F0F0),
                            child: avatarChild,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          displayEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    );
                  },
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
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MyLostReportsScreen(repo: widget.lostRepo),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuTile(
                      title: "Laporan Penemuan Saya",
                      subtitle: "Barang yang Anda temukan",
                      icon: Icons.travel_explore_rounded,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MyFoundReportsScreen(repo: widget.foundRepo),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuTile(
                      title: "Kecocokan (Matches)",
                      subtitle: "Lihat hasil pencocokan barang Anda",
                      icon: Icons.hub_rounded,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MyMatchesScreen(repo: widget.matchRepo),
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
                      onTap: _handleLogout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
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
