import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';
import 'package:tusfind_frontend/core/models/match_report_model.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';
import 'package:tusfind_frontend/core/services/auth_service.dart'; // Import Auth Service
import 'package:tusfind_frontend/core/widgets/app_bar.dart';
import 'package:tusfind_frontend/core/widgets/match_report_card.dart';
import 'package:tusfind_frontend/core/widgets/toast.dart';
import 'package:tusfind_frontend/features/match_report/screen/match_detail_screen.dart';

class MatchListScreen extends StatefulWidget {
  final MatchRepository repo;

  const MatchListScreen({super.key, required this.repo});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  late Future<List<MatchReport>> _future;
  bool _isAutoMatching = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _refresh();
  }

  Future<void> _loadCurrentUser() async {
    final id = await AuthService.getStoredUserId();
    if (mounted) {
      setState(() => _currentUserId = id);
    }
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getMatches();
    });
  }

  Future<void> _runAutoMatch() async {
    setState(() => _isAutoMatching = true);

    try {
      await widget.repo.autoMatch();
      if (mounted) {
        TusToast.show(
          context,
          "Auto-match completed successfully!",
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        TusToast.show(
          context,
          "Error: $e",
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAutoMatching = false);
        _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(title: 'Hasil Pencocokan', icon: Icons.hub),
      body: FutureBuilder<List<MatchReport>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final matches = snapshot.data!;

          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kecocokan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jalankan auto-match untuk mencari\nkemungkinan kecocokan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isAutoMatching ? null : _runAutoMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: _isAutoMatching
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(
                      _isAutoMatching ? "Processing..." : "Jalankan Auto Match",
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 80),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];

                // Check ownership
                final bool isMine = _currentUserId != null &&
                    _currentUserId == match.itemLost.userId;

                return MatchReportCard(
                  lostItem: match.itemLost.item?.name ??
                      match.itemLost.customItemName ??
                      'Unknown Lost Item',
                  foundItem: match.itemFound.item?.name ??
                      match.itemFound.customItemName ??
                      'Unknown Found Item',
                  score: match.matchScore,
                  status: match.status,
                  isMine: isMine, // <--- Pass the new boolean
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MatchDetailScreen(repo: widget.repo, id: match.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      // ... Floating Action Button remains the same ...
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 130),
        child: FutureBuilder<List<MatchReport>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox();
            }
            return FloatingActionButton.extended(
              backgroundColor: AppColor.primary,
              onPressed: _isAutoMatching ? null : _runAutoMatch,
              icon: _isAutoMatching
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.auto_fix_high, color: Colors.white),
              label: Text(
                _isAutoMatching ? "Scanning..." : "Auto Match",
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}