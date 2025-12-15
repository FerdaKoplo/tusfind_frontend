import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/core/repositories/item_found_repository.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_list_screen.dart';
import 'package:tusfind_frontend/features/item_found/screen/found_list_screen.dart';
import 'package:tusfind_frontend/features/match_report/screen/match_list_screen.dart';

void main() {
  final apiService = ApiService();

  runApp(
    TusFindApp(
      lostRepo: ItemLostRepository(apiService),
      foundRepo: ItemFoundRepository(apiService),
      matchRepo: MatchRepository(apiService),
    ),
  );
}

class TusFindApp extends StatelessWidget {
  final ItemLostRepository lostRepo;
  final ItemFoundRepository foundRepo;
  final MatchRepository matchRepo;

  const TusFindApp({
    super.key,
    required this.lostRepo,
    required this.foundRepo,
    required this.matchRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(
        lostRepo: lostRepo,
        foundRepo: foundRepo,
        matchRepo: matchRepo,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ItemLostRepository lostRepo;
  final ItemFoundRepository foundRepo;
  final MatchRepository matchRepo;

  const MainScreen({
    super.key,
    required this.lostRepo,
    required this.foundRepo,
    required this.matchRepo,
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
    ];

    return Scaffold(
      body: screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: Colors.grey,
        items: [
          _navItem(
            icon: Icons.report,
            label: 'Lost',
            index: 0,
          ),
          _navItem(
            icon: Icons.find_in_page,
            label: 'Found',
            index: 1,
          ),
          _navItem(
            icon: Icons.link,
            label: 'Matches',
            index: 2,
          ),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected
                  ? AppColor.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Icon(icon),
      ),
    );
  }
}
