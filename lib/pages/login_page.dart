import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';
import 'package:tusfind_frontend/services/secure_storage.dart';
import 'package:tusfind_frontend/core/repositories/login_repository.dart';
import 'package:tusfind_frontend/features/admin/screen/admin_screen.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool loading = false;

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> handleLogin() async {
    final email = emailController.text;
    final password = passController.text;

    // --- VALIDASI ---
    if (email.isEmpty) {
      _showSnackBar("Email tidak boleh kosong");
      return;
    }
    if (!email.endsWith("@gmail.com")) {
      _showSnackBar("Email harus menggunakan @gmail.com");
      return;
    }
    if (password.isEmpty) {
      _showSnackBar("Password tidak boleh kosong");
      return;
    }

    setState(() => loading = true);

    try {
      final apiService = ApiService();
      final repo = LoginRepository(apiService);

      final res = await repo.login(
        email: email,
        password: password,
      );

      if (res['status'] == 'success' || res['success'] == true) {
        final token = res['token'];
        
        // Simpan token ke storage aman
        await SecureStorage.saveToken(token);

        if (!mounted) return;
        _showSnackBar("Selamat Datang!", isError: false);

        // Pindah ke Dashboard Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen(token: token)),
        );
      } else {
        _showSnackBar(res['message'] ?? "Login Gagal");
      }
    } catch (e) {
      _showSnackBar("Email atau Password salah");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("LOGIN ADMIN"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(CupertinoIcons.lock_shield, size: 80, color: Colors.blue),
            const SizedBox(height: 40),
            
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Gmail",
                prefixIcon: Icon(CupertinoIcons.mail),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(CupertinoIcons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : handleLogin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: loading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text("MASUK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("Belum punya akun? Daftar di sini"),
            ),
          ],
        ),
      ),
    );
  }
}