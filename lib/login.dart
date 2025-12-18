import 'package:flutter/material.dart';
import 'package:tusfind_frontend/services/secure_storage.dart';
import 'package:tusfind_frontend/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController();
void login() async {
  if (!formKey.currentState!.validate()) return;

  final res = await ApiService.login({
    'email': email.text,
    'password': pass.text,
  });

  if (res['success'] == true) {
    await SecureStorage.saveToken(res['token']);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Login Berhasil")));

    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(res['message'])));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: email,
                decoration: InputDecoration(labelText: "Email"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Email wajib diisi" : null,
              ),
              TextFormField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Password wajib diisi" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: Text("Login")),
            ],
          ),
        ),
      ),
    );
  }
}
