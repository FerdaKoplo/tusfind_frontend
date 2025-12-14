import 'package:flutter/material.dart';

class ItemReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onTap;

  const ItemReportCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  Color _statusColor() {
    switch (status) {
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

  String _statusText() {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Status Indicator
              Container(
                width: 10,
                height: 50,
                decoration: BoxDecoration(
                  color: _statusColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status Chip
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusText(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
