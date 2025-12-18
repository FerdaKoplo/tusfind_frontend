import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? _image;
  final picker = ImagePicker();
  bool loading = false;

  Future<void> pickCamera() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() => _image = File(file.path));
    }
  }

  Future<void> pickGallery() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _image = File(file.path));
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    setState(() => loading = true);

    final uri = Uri.parse("http://10.0.2.2:8000/api/upload-image");
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('image', _image!.path),
    );

    final response = await request.send();

    setState(() => loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload berhasil")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload gagal")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Image")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _image == null
                  ? const Center(child: Text("No Image Selected"))
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickCamera,
              child: const Text("Camera"),
            ),
            ElevatedButton(
              onPressed: pickGallery,
              child: const Text("Gallery"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loading ? null : uploadImage,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
