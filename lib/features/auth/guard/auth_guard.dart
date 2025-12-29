// ariana
import 'package:flutter/material.dart';
import 'package:tusfind_frontend/features/auth/screen/login_screen.dart';
import 'package:tusfind_frontend/features/admin/screen/admin_screen.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_list_screen.dart';
import 'package:tusfind_frontend/features/auth/services/auth_service.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getStoredToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;

        if (token != null && token.isNotEmpty) {
          return AdminScreen(token: token); 
        }

        return const LoginPage();
      },
    );
  }
}
