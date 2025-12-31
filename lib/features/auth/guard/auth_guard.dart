// ariana
import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/repositories/item_lost_repository.dart';
import 'package:tusfind_frontend/features/auth/screen/login_screen.dart';
import 'package:tusfind_frontend/features/admin/screen/admin_screen.dart';
import 'package:tusfind_frontend/features/item_lost/screen/lost_list_screen.dart';
import 'package:tusfind_frontend/core/services/auth_service.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getAuthData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        final token = data?['token'];
        final role = data?['role'];

        if (token != null && token.isNotEmpty) {
          if (role == 'admin') {
            return AdminScreen(token: token);
          } else {
            final apiService = ApiService();
            return LostListScreen(repo: ItemLostRepository(apiService));
          }
        }

        return const LoginPage();
      },
    );
  }

  Future<Map<String, String?>> _getAuthData() async {
    final token = await AuthService.getStoredToken();
    final role = await AuthService.getStoredRole();
    return {'token': token, 'role': role};
  }
}
