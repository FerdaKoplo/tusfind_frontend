import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tusfind_frontend/core/constants/colors.dart';

// ivan
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData? icon;
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppAppBar({
    super.key,
    this.icon,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,

      systemOverlayStyle: SystemUiOverlayStyle.light,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),

      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primaryLight,
              // Create a slightly darker variant for the gradient end
              // If you don't have a secondary color, standard manipulation works:
              AppColor.primaryLight.withOpacity(0.8),
            ],
          ),
        ),
      ),

      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      leading: showBackButton
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      )
          : null,

      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10); // Slightly taller
}