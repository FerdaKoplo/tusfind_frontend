//ariana
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tusfind_frontend/core/repositories/image_upload_repository.dart';
import 'package:tusfind_frontend/core/widgets/image_picker_widget.dart';

class ImageUploadScreen extends StatefulWidget {
  final int itemId;

  const ImageUploadScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  bool _isLoading = false;

  late ImageUploadRepository repository;

  @override
  void initState() {
    super.initState();
    repository = ImageUploadRepository();
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    try {
      await repository.uploadItemImage(
        itemId: widget.itemId,
        image: _image!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload berhasil")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload gagal: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Gambar")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ImagePickerWidget(
              image: _image,
              onImagePicked: (img) {
                setState(() => _image = img);
              },
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _uploadImage,
                      child: const Text("Upload"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
