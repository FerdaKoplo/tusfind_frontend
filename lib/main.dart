import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';
import 'package:tusfind_frontend/core/repositories/profile_repository.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_list_screen.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_list_screen.dart';
import 'package:tusfind_frontend/features/match_report/screen/match_list_screen.dart';
import 'package:tusfind_frontend/features/profile/screen/profile_stats_screen.dart';

void main() {
  final apiService = ApiService();

  runApp(
    TusFindApp(
      lostRepo: ItemLostRepository(apiService),
      foundRepo: ItemFoundRepository(apiService),
      matchRepo: MatchRepository(apiService),
      profileRepo: ProfileRepository(apiService)
    ),
  );
}

class TusFindApp extends StatelessWidget {
  final ItemLostRepository lostRepo;
  final ItemFoundRepository foundRepo;
  final MatchRepository matchRepo;
  final ProfileRepository profileRepo;

  const TusFindApp({
    super.key,
    required this.lostRepo,
    required this.foundRepo,
    required this.matchRepo,
    required this.profileRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
        useMaterial3: true,
      ),
      home: MainScreen(
        lostRepo: lostRepo,
        foundRepo: foundRepo,
        matchRepo: matchRepo,
        profileRepo: profileRepo,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ItemLostRepository lostRepo;
  final ItemFoundRepository foundRepo;
  final MatchRepository matchRepo;
  final ProfileRepository profileRepo;

  const MainScreen({
    super.key,
    required this.lostRepo,
    required this.foundRepo,
    required this.matchRepo,
    required this.profileRepo,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      LostListScreen(repo: widget.lostRepo),
      FoundListScreen(repo: widget.foundRepo),
      MatchListScreen(repo: widget.matchRepo),
      ProfileScreen(
        profileRepo: widget.profileRepo,
        lostRepo: widget.lostRepo,
        foundRepo: widget.foundRepo,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.search_off_rounded,
              label: 'Kehilangan',
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.travel_explore_rounded,
              label: 'Ditemukan',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.hub_rounded,
              label: 'Cocok',
              index: 2,
            ),
            // 8. Add Profile Tab
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() => _currentIndex = index);
          HapticFeedback.lightImpact();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColor.primary : Colors.grey[500],
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: isSelected
                      ? const EdgeInsets.only(left: 8)
                      : EdgeInsets.zero,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}