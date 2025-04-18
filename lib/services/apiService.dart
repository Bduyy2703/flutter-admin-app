import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../models/shop.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();

  // Gửi yêu cầu không cần xác thực (như login)
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

  // Gửi yêu cầu cần xác thực (như get shops)
  Future<List<Shop>> getShops({int pageNo = 0, int pageSize = 10}) async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('${ApiConstants.authBaseUrl}${ApiConstants.shops}?pageNo=$pageNo&pageSize=$pageSize&sortBy=id&sortDir=asc'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final shops = (data['content'] as List).map((json) => Shop.fromJson(json)).toList();
      return shops;
    } else {
      throw Exception('Failed to load shops: ${response.body}');
    }
  }

  // Lấy danh sách phòng, xử lý trường hợp rỗng
  Future<List<dynamic>> getAvailableRooms(int shopId) async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('${ApiConstants.authBaseUrl}${ApiConstants.rooms}/$shopId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final rooms = jsonDecode(response.body);
      if (rooms.isEmpty) {
        return []; // Trả về danh sách rỗng thay vì gây lỗi
      }
      return rooms;
    } else {
      throw Exception('Failed to load rooms: ${response.body}');
    }
  }
}