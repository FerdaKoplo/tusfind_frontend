import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tusfind_frontend/services/api_service.dart'; // Sesuaikan path ApiService kamu
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk mengambil input teks
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool loading = false;

  // Fungsi Register (Gaya Logic-in-Page seperti temanmu)
  Future<void> handleRegister() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passController.text;

    // --- 1. VALIDASI (Ketentuan yang kamu minta) ---
    if (name.isEmpty) {
      _showSnackBar("Username tidak boleh kosong");
      return;
    }

    if (!email.endsWith("@gmail.com")) {
      _showSnackBar("Email harus menggunakan domain @gmail.com");
      return;
    }

    if (password.length < 8) {
      _showSnackBar("Password minimal harus 8 karakter");
      return;
    }

    // --- 2. PROSES API ---
    setState(() => loading = true);

    try {
      // Memanggil ApiService secara static seperti contoh temanmu
      final res = await ApiService.register({
        'name': name,
        'email': email,
        'password': password,
      });

      if (res['success'] == true) {
        if (!mounted) return;
        _showSnackBar("Registrasi Berhasil!", isError: false);

        // Pindah ke halaman Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        _showSnackBar(res['message'] ?? "Registrasi Gagal");
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("DAFTAR AKUN"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // INPUT USERNAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(CupertinoIcons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // INPUT EMAIL
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "contoh@gmail.com",
                prefixIcon: Icon(CupertinoIcons.mail),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // INPUT PASSWORD
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

            // TOMBOL DAFTAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : handleRegister,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: loading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Sudah punya akun? Login di sini"),
            ),
          ],
        ),
      ),
    );
  }
}