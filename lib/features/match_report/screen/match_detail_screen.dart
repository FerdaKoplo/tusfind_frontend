import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/models/match_report_model.dart';
import 'package:tusfind_frontend/core/repositories/match_report_repository.dart';
import 'package:tusfind_frontend/core/services/auth_service.dart';
import 'package:tusfind_frontend/core/widgets/app_bar.dart';

class MatchDetailScreen extends StatefulWidget {
  final MatchRepository repo;
  final int id;

  const MatchDetailScreen({super.key, required this.repo, required this.id});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool _isProcessing = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final id = await AuthService.getStoredUserId();
    if (mounted) {
      setState(() => _currentUserId = id);
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  // ... [Keep your helper widgets _buildInfoRow and _buildItemCard exactly the same] ...
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String headerTitle,
    required String itemName,
    required String location,
    required String description,
    required String reporterName,
    required int reporterId,
    required Color color,
    required IconData icon,
  }) {
    final bool isMyItem = _currentUserId != null && _currentUserId == reporterId;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isMyItem ? color.withOpacity(0.05) : Colors.white,
        border: isMyItem
            ? Border.all(color: color.withOpacity(0.3), width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(icon, size: 16, color: color),
                              const SizedBox(width: 8),
                              Text(
                                headerTitle.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          if (isMyItem)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Milik Saya",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMyItem ? Colors.white : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: isMyItem
                              ? Border.all(color: color.withOpacity(0.2))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 16, color: color),
                            const SizedBox(width: 8),
                            Text(
                              isMyItem ? "Anda ($reporterName)" : reporterName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color.withOpacity(0.8),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      _buildInfoRow(
                          Icons.location_on_outlined, "Location", location),
                      _buildInfoRow(Icons.description_outlined, "Description",
                          description),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(bool isConfirm) async {
    setState(() => _isProcessing = true);
    try {
      if (isConfirm) {
        await widget.repo.confirmMatch(widget.id);
      } else {
        await widget.repo.rejectMatch(widget.id);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppAppBar(
        title: 'Detail Kecocokan',
        showBackButton: true,
        icon: Icons.compare_arrows,
      ),
      body: FutureBuilder<MatchReport>(
        future: widget.repo.getMatchDetail(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Match not found"));
          }

          final match = snapshot.data!;
          final scoreColor = _getScoreColor(match.matchScore);

          // --- LOGIC: CHECK OWNERSHIP ---
          // The action buttons are enabled ONLY if the current user is the one who lost the item.
          final bool isOwner = _currentUserId != null &&
              _currentUserId == match.itemLost.userId;
          // ------------------------------

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ... [Score and Status Widgets remain the same] ...
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: match.matchScore / 100,
                                    strokeWidth: 8,
                                    backgroundColor: scoreColor.withOpacity(0.1),
                                    valueColor:
                                    AlwaysStoppedAnimation(scoreColor),
                                  ),
                                ),
                                Text(
                                  "${match.matchScore}%",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(match.status.toUpperCase()),
                              backgroundColor: scoreColor,
                              side: BorderSide.none,
                              labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )
                          ],
                        ),
                      ),

                      _buildItemCard(
                        headerTitle: "Barang Hilang (Lost)",
                        itemName: match.itemLost.item?.name ??
                            match.itemLost.customItemName ??
                            "Unknown Item",
                        location: match.itemLost.lostLocation ?? "No location",
                        description:
                        match.itemLost.description ?? "No description",
                        reporterName:
                        match.itemLost.user?.name ?? "Unknown User",
                        reporterId: match.itemLost.userId,
                        color: Colors.orange,
                        icon: Icons.search_off,
                      ),

                      const SizedBox(height: 16),

                      _buildItemCard(
                        headerTitle: "Kandidat Ditemukan",
                        itemName: match.itemFound.item?.name ??
                            match.itemFound.customItemName ??
                            "Unknown Item",
                        location:
                        match.itemFound.foundLocation ?? "No location",
                        description:
                        match.itemFound.description ?? "No description",
                        reporterName:
                        match.itemFound.user?.name ?? "Unknown User",
                        reporterId: match.itemFound.userId,
                        color: Colors.blue,
                        icon: Icons.check_circle_outline,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (match.status.toLowerCase() == 'pending')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- MESSAGE IF DISABLED ---
                      if (!isOwner)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Hanya pemilik barang hilang yang dapat mengkonfirmasi.",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // ---------------------------

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              // Disable if not owner or processing
                              onPressed: (_isProcessing || !isOwner)
                                  ? null
                                  : () => _handleAction(false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(
                                  // Grey out border if disabled
                                  color: isOwner
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("Tolak"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              // Disable if not owner or processing
                              onPressed: (_isProcessing || !isOwner)
                                  ? null
                                  : () => _handleAction(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                disabledBackgroundColor: Colors.grey[300], // Grey bg when disabled
                                disabledForegroundColor: Colors.grey[500], // Grey text when disabled
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                                  : const Text("Konfirmasi",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}