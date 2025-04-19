import 'package:apehome_admin/screens/create_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomTypeDetailsScreen extends StatefulWidget {
  final int roomTypeId;
  final int shopId;

  const RoomTypeDetailsScreen({Key? key, required this.roomTypeId, required this.shopId})
      : super(key: key);

  @override
  _RoomTypeDetailsScreenState createState() => _RoomTypeDetailsScreenState();
}

class _RoomTypeDetailsScreenState extends State<RoomTypeDetailsScreen> {
  Map<String, dynamic>? _roomTypeDetails;
  List<dynamic> _rooms = [];
  List<dynamic> _availableRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoomTypeDetails();
    _fetchRooms();
    _fetchAvailableRooms();
  }

  Future<void> _fetchRoomTypeDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/room-types/${widget.roomTypeId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Raw response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _roomTypeDetails = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải chi tiết loại phòng: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _fetchRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/rooms/shops/${widget.shopId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Raw response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _rooms = data.where((room) => room['roomTypeId'] == widget.roomTypeId).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách phòng: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _fetchAvailableRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/rooms/available/shops/${widget.shopId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Raw response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _availableRooms = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách phòng trống: ${response.statusCode}')),
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

  bool _isRoomAvailable(int roomId) {
    return _availableRooms.any((room) => room['id'] == roomId);
  }

  void _navigateToCreateRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRoomScreen(
          shopId: widget.shopId,
          roomTypeId: widget.roomTypeId,
        ),
      ),
    ).then((_) {
      _fetchRooms();
      _fetchAvailableRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      appBar: AppBar(
        title: Text(
          'Chi Tiết Loại Phòng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4EA0B7),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
          : _roomTypeDetails == null
              ? Center(
                  child: Text(
                    'Không tìm thấy loại phòng',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thông tin loại phòng
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _roomTypeDetails!['name'] ?? 'Không tên',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Mô tả: ${_roomTypeDetails!['description'] ?? 'Không có mô tả'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Nút tạo phòng mới
                        Center(
                          child: ElevatedButton(
                            onPressed: _navigateToCreateRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4EA0B7),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Tạo Phòng Mới',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Danh sách phòng
                        Text(
                          'Danh Sách Phòng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        SizedBox(height: 10),
                        _rooms.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'Chưa có phòng nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _rooms.length,
                                itemBuilder: (context, index) {
                                  final room = _rooms[index];
                                  final isAvailable = _isRoomAvailable(room['id']);
                                  return Card(
                                    elevation: 2,
                                    margin: EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      leading: Icon(
                                        Icons.room,
                                        color: isAvailable ? Colors.green : Colors.red,
                                        size: 30,
                                      ),
                                      title: Text(
                                        room['name'] ?? 'Phòng ${room['id']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D2D2D),
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Trạng thái: ${isAvailable ? 'Trống' : 'Đã sử dụng'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          // TODO: Thêm logic xóa phòng
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Xóa phòng ${room['id']}')),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}