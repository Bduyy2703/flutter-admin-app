import 'package:apehome_admin/screens/create_room_screen.dart';
import 'package:apehome_admin/screens/edit_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

class RoomsScreen extends StatefulWidget {
  final int shopId;

  const RoomsScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<dynamic> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/rooms/shops/${widget.shopId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Lấy danh sách phòng - Dữ liệu thô: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _rooms = data['content'];
        });
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi tải danh sách phòng: ${response.statusCode}');
      }
    } catch (e) {
      print('Lấy danh sách phòng - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách phòng. Vui lòng thử lại!')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRoom(int roomId, String roomName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phòng "$roomName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/rooms/$roomId');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Xóa phòng - Mã trạng thái: ${response.statusCode}');
      print('Xóa phòng - Phản hồi: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _rooms.removeWhere((room) => room['id'] == roomId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa phòng thành công')),
        );
        await _fetchRooms(); // Làm mới danh sách
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phòng không tồn tại hoặc đã bị xóa')),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn không có quyền xóa phòng này')),
        );
      } else {
        String errorMessage = 'Lỗi khi xóa phòng: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Xóa phòng - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa phòng. Lỗi: $e')),
      );
    }
  }

  void _navigateToCreateRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateRoomScreen(shopId: widget.shopId)),
    ).then((_) => _fetchRooms());
  }

  void _navigateToEditRoom(Map<String, dynamic> room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditRoomScreen(room: room)),
    ).then((_) => _fetchRooms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      body: RefreshIndicator(
        onRefresh: _fetchRooms,
        color: Color(0xFF4EA0B7),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Danh Sách Phòng',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1.2,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: FadeInUp(
                  duration: Duration(milliseconds: 500),
                  child: ElevatedButton(
                    onPressed: _navigateToCreateRoom,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Tạo Phòng Mới',
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
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7))),
                    )
                  : _rooms.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.room, size: 50, color: Colors.grey[400]),
                                SizedBox(height: 8),
                                Text(
                                  'Chưa có phòng nào',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: List.generate(_rooms.length, (index) {
                              final room = _rooms[index];
                              return FadeInUp(
                                duration: Duration(milliseconds: 400 + (index * 100)),
                                child: Card(
                                  elevation: 4,
                                  margin: EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        colors: [Colors.white, Colors.grey[100]!],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue[100],
                                        child: Icon(
                                          Icons.room,
                                          color: Color(0xFF4EA0B7),
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        room['name'] ?? 'Không tên',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D2D2D),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 5),
                                          Text(
                                            'Loại: ${(room['roomType']?['name'] ?? 'comfortable room').toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Mô tả: ${room['description'] ?? 'Không có mô tả'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Giá: ${room['price']?.toString() ?? 'Không xác định'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Trạng thái: ${room['status'] ?? 'Không xác định'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF4EA0B7),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Color(0xFF4EA0B7)),
                                            onPressed: () => _navigateToEditRoom(room),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteRoom(
                                              room['id'],
                                              room['name'] ?? 'Không tên',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}