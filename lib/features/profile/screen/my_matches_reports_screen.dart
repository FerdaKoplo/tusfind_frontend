import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/match_report_model.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/match_report_card.dart';
import 'package:tusfind_frontend/features/match_report/screen/match_detail_screen.dart';

class MyMatchesScreen extends StatefulWidget {
  final MatchRepository repo;
  const MyMatchesScreen({super.key, required this.repo});

  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  late Future<List<MatchReport>> _future;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getMyMatches(status: _selectedStatus);
    });
  }

  void _onFilterChanged(String? status) {
    setState(() {
      _selectedStatus = (_selectedStatus == status) ? null : status; // Toggle
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppAppBar(
        title: "Kecocokan Saya",
        showBackButton: true,
        icon: Icons.hub_rounded,
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
                  _buildFilterChip("Confirmed", "confirmed"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Rejected", "rejected"),
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<MatchReport>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final matches = snapshot.data ?? [];

                if (matches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link_off, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ada kecocokan",
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
                    itemCount: matches.length,
                    itemBuilder: (_, index) {
                      final match = matches[index];
                      return MatchReportCard(
                        lostItem: match.itemLost.item?.name ?? '-',
                        foundItem: match.itemFound.item?.name ?? '-',
                        score: match.matchScore,
                        status: match.status,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MatchDetailScreen(repo: widget.repo, id: match.id),
                            ),
                          );
                        },
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