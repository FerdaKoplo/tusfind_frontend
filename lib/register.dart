import 'package:flutter/material.dart';
import 'package:tusfind_frontend/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  bool loading = false;

  void register() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final res = await ApiService.register({
      'name': nameC.text,
      'email': emailC.text,
      'phone': phoneC.text,
      'password': passC.text,
      'password_confirmation': confirmC.text
    });

    setState(() => loading = false);

    if (res['success'] == true) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameC,
                decoration: InputDecoration(labelText: "Nama"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nama wajib diisi" : null,
              ),
              TextFormField(
                controller: emailC,
                decoration: InputDecoration(labelText: "Email"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Email wajib diisi" : null,
              ),
              TextFormField(
                controller: phoneC,
                decoration: InputDecoration(labelText: "No Telp"),
                validator: (v) =>
                    v == null || v.isEmpty ? "No Telp wajib diisi" : null,
              ),
              TextFormField(
                controller: passC,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
              TextFormField(
                controller: confirmC,
                obscureText: true,
                decoration: InputDecoration(labelText: "Konfirmasi Password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : register,
                child: Text("Daftar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
