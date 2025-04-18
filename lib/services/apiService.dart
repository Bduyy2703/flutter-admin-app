import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apehome_admin/constants/api_constants.dart';
import 'package:apehome_admin/models/shop.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.noAuthBaseUrl}${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Các hàm khác như getShops, getAvailableRooms...
}