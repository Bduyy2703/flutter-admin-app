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
Future<Map<String, dynamic>?> getShopById(int shopId, String token) async {
  final response = await http.get(
    Uri.parse('${ApiConstants.authBaseUrl}/shops/$shopId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final decodedBody = utf8.decode(response.bodyBytes);
    return jsonDecode(decodedBody);
  } else {
    throw Exception('Lỗi khi lấy thông tin cửa hàng $shopId: ${response.body}');
  }
}
  // Lấy danh sách bookings
  Future<List<dynamic>?> getBookings(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.authBaseUrl}/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch bookings: ${response.body}');
    }
  }

Future<List<dynamic>?> getBookingsByShopId(int shopId, String token) async {
  // Thêm tham số phân trang
  final uri = Uri.parse('${ApiConstants.authBaseUrl}/bookings/shops/$shopId').replace(
    queryParameters: {
      'pageNo': '0',
      'pageSize': '30',
      'sortBy': 'id',
      'sortDir': 'asc',
    },
  );

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final decodedBody = utf8.decode(response.bodyBytes); // Xử lý mã hóa UTF-8
    final data = jsonDecode(decodedBody);
    // Kiểm tra nếu phản hồi là phân trang
    if (data is Map<String, dynamic> && data.containsKey('content')) {
      return data['content']; // Trả về danh sách booking
    }
    return data; // Trả về danh sách trực tiếp nếu không phân trang
  } else {
    throw Exception('Lỗi khi lấy booking cho shop $shopId: ${response.body}');
  }
}

  // Hủy booking
  Future<Map<String, dynamic>?> cancelBooking(int bookingId, String token) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.authBaseUrl}/bookings/cancel/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': 'CANCELLED',
      }),
    );

    if (response.statusCode == 200) {
      return {'status': 'success'};
    } else {
      throw Exception('Failed to cancel booking: ${response.body}');
    }
  }

  // Lấy chi tiết booking
 Future<Map<String, dynamic>?> getBookingDetails(int bookingId, String token) async {
  final response = await http.get(
    Uri.parse('${ApiConstants.authBaseUrl}/bookings/$bookingId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final decodedBody = utf8.decode(response.bodyBytes); // Xử lý UTF-8
    return jsonDecode(decodedBody);
  } else {
    throw Exception('Lỗi khi lấy chi tiết booking $bookingId: ${response.body}');
  }
}

  // Lấy danh sách shops theo userId
  Future<List<dynamic>?> getShopsByUserId(String userId, String token) async {
    final uri = Uri.parse('${ApiConstants.authBaseUrl}/shops/users/$userId').replace(
      queryParameters: {
        'pageNo': '0',
        'pageSize': '30',
        'sortBy': 'id',
        'sortDir': 'asc',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      return data['content'] ?? data;
    } else {
      throw Exception('Failed to fetch shops for user $userId: ${response.body}');
    }
  }
}