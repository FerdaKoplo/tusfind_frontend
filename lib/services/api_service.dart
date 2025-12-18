import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tusfind_frontend/models/item_models.dart';

class ApiService {
  static const baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> register(Map data) async {
    final res = await http.post(Uri.parse('$baseUrl/register'), body: data);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(Map data) async {
    final res = await http.post(Uri.parse('$baseUrl/login'), body: data);
    return jsonDecode(res.body);
  }
  
  static Future<List<Item>> getItems({
    required String type,
    String? category,
    String? location,
  }) async {
    final uri = Uri.parse("$baseUrl/$type-items").replace(queryParameters: {
      if (category != null) 'category': category,
      if (location != null) 'location': location,
    });

    final res = await http.get(uri);
    final data = jsonDecode(res.body);

    return (data['data'] as List)
        .map((e) => Item.fromJson(e))
        .toList();
  }
}
