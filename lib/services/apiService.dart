import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/shop.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
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

  Future<List<Shop>> getShops({int pageNo = 0, int pageSize = 10}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.shops}?pageNo=$pageNo&pageSize=$pageSize&sortBy=id&sortDir=asc'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final shops = (data['content'] as List).map((json) => Shop.fromJson(json)).toList();
      return shops;
    } else {
      throw Exception('Failed to load shops: ${response.body}');
    }
  }
}