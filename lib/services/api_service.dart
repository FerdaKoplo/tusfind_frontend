import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<Map<String, dynamic>> register(Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      body: data,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      body: data,
    );
    return jsonDecode(res.body);
  }
}
