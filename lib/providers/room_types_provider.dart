import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomTypesProvider with ChangeNotifier {
  List<dynamic> _roomTypes = [];
  bool _isLoading = false;
  bool _isModalLoading = false;
  String? _errorMessage;

  List<dynamic> get roomTypes => _roomTypes;
  bool get isLoading => _isLoading;
  bool get isModalLoading => _isModalLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRoomTypes(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/room-types');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        _roomTypes = data;
      } else {
        _errorMessage = 'Lỗi khi tải danh sách loại phòng: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRoomType(BuildContext context, int roomTypeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/room-types/$roomTypeId');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _roomTypes.removeWhere((roomType) => roomType['id'] == roomTypeId);
        _errorMessage = null;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa loại phòng thành công')),
        );
      } else {
        _errorMessage = 'Lỗi khi xóa loại phòng: ${response.statusCode}';
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa loại phòng: ${response.statusCode}')),
        );
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<bool> createOrUpdateRoomType(
    BuildContext context,
    String name,
    String note,
    int? roomTypeId,
  ) async {
    _isModalLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        _isModalLoading = false;
        notifyListeners();
        return false;
      }

      final uri = Uri.parse(
        roomTypeId == null
            ? 'http://192.168.41.175:9090/api/v1/room-types'
            : 'http://192.168.41.175:9090/api/v1/room-types/$roomTypeId',
      );

      final response = roomTypeId == null
          ? await http.post(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                'name': name,
                'note': note,
              }),
            )
          : await http.put(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                'name': name,
                'note': note,
              }),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchRoomTypes(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomTypeId == null ? 'Tạo loại phòng thành công' : 'Cập nhật loại phòng thành công',
            ),
          ),
        );
        return true;
      } else {
        _errorMessage = 'Lỗi: ${response.statusCode} - ${response.body}';
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.statusCode} - ${response.body}')),
        );
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
      return false;
    } finally {
      _isModalLoading = false;
      notifyListeners();
    }
  }
}