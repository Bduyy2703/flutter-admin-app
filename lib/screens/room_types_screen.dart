import 'package:apehome_admin/screens/create_room_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apehome_admin/screens/room_type_details.dart';

// room_types_screen.dart
class RoomTypesScreen extends StatefulWidget {
  const RoomTypesScreen({Key? key}) : super(key: key); // Xóa tham số shopId

  @override
  _RoomTypesScreenState createState() => _RoomTypesScreenState();
}

class _RoomTypesScreenState extends State<RoomTypesScreen> {
  List<dynamic> _roomTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoomTypes();
  }

  Future<void> _fetchRoomTypes() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/room-types');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Raw response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _roomTypes = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách loại phòng: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRoomType(int roomTypeId) async {
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
        setState(() {
          _roomTypes.removeWhere((roomType) => roomType['id'] == roomTypeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa loại phòng thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa loại phòng: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _navigateToCreateRoomType() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateRoomTypeScreen()), // Xóa tham số shopId
    ).then((_) => _fetchRoomTypes());
  }

  void _navigateToRoomTypeDetails(int roomTypeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomTypeDetailsScreen(
          roomTypeId: roomTypeId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      appBar: AppBar(
        title: Text(
          'Danh Sách Loại Phòng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4EA0B7),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ElevatedButton(
              onPressed: _navigateToCreateRoomType,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4EA0B7),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Tạo Loại Phòng Mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
                : _roomTypes.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có loại phòng nào',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(15),
                        itemCount: _roomTypes.length,
                        itemBuilder: (context, index) {
                          final roomType = _roomTypes[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              title: Text(
                                roomType['name'] ?? 'Không tên',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              subtitle: Text(
                                'Mô tả: ${roomType['description'] ?? 'Không có mô tả'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.visibility, color: Color(0xFF4EA0B7)),
                                    onPressed: () => _navigateToRoomTypeDetails(roomType['id']),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Color(0xFF4EA0B7)),
                                    onPressed: () {
                                      // TODO: Điều hướng đến màn hình chỉnh sửa loại phòng
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Chuyển đến trang chỉnh sửa loại phòng')),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteRoomType(roomType['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}