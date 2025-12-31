import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tusfind_frontend/core/services/api_service.dart';

class ImageUploadRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> uploadItemImage({
    required int itemId,
    required File image,
  }) async {
    // 1. Ambil token
    final token = await _storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan, user belum login');
    }

    // 2. Buat ApiService DENGAN token
    final api = ApiService(token: token);

    // 3. Siapkan multipart data
    final fileName = image.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    // 4. Upload
    await api.post(
      '/items/$itemId/image',
      formData,
    );
  }
}
