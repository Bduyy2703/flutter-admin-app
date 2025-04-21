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
  String _selectedFilter = 'Tất cả'; // Biến lưu trạng thái bộ lọc

  // Danh sách các trạng thái để lọc
  final List<Map<String, String>> _statusFilters = [
    {'value': 'Tất cả', 'label': 'Tất cả'},
    {'value': 'AVAILABLE', 'label': 'Sẵn sàng'},
    {'value': 'OCCUPIED', 'label': 'Đã sử dụng'},
    {'value': 'MAINTENANCE', 'label': 'Bảo trì'},
    {'value': 'CLOSED', 'label': 'Đóng cửa'},
  ];

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

  // Lọc danh sách phòng dựa trên trạng thái
  List<dynamic> get _filteredRooms {
    if (_selectedFilter == 'Tất cả') {
      return _rooms;
    }
    return _rooms.where((room) {
      final roomStatus = (room['status'] ?? 'Không xác định').toString().toUpperCase();
      return roomStatus == _selectedFilter.toUpperCase();
    }).toList();
  }

  // Hàm trả về màu sắc và icon cho trạng thái
  Map<String, dynamic> _getStatusStyle(String? status) {
    switch (status?.toUpperCase()) {
      case 'AVAILABLE':
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'OCCUPIED':
        return {
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      case 'MAINTENANCE':
        return {
          'color': Colors.orange,
          'icon': Icons.build,
        };
      case 'CLOSED':
        return {
          'color': Colors.grey,
          'icon': Icons.lock,
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.help,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      appBar: AppBar(
        title: const Text(
          'Danh Sách Phòng',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4EA0B7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Nút Tạo Phòng Mới
          Padding(
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
                  elevation: 10,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.black54,
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
                        Icon(Icons.add, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Tạo Phòng Mới',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bộ lọc trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildStatusFilterChip(filter['value']!, filter['label']!),
                  );
                }).toList(),
              ),
            ),
          ),
          // Danh sách phòng
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRooms,
              color: Color(0xFF4EA0B7),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            color: Color(0xFF4EA0B7),
                            backgroundColor: Colors.grey[200],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Đang tải danh sách phòng...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : _filteredRooms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.room, size: 50, color: Colors.grey[400]),
                              SizedBox(height: 8),
                              Text(
                                'Không có phòng nào phù hợp',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          itemCount: _filteredRooms.length,
                          itemBuilder: (context, index) {
                            final room = _filteredRooms[index];
                            final statusStyle = _getStatusStyle(room['status']);
                            return FadeInUp(
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              child: Card(
                                elevation: 6,
                                margin: EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [Colors.white, Colors.grey[50]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      radius: 24,
                                      child: Icon(
                                        Icons.room,
                                        color: Color(0xFF4EA0B7),
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      room['name'] ?? 'Không tên',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Loại: ${(room['roomType']?['name'] ?? 'comfortable room').toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Mô tả: ${room['description'] ?? 'Không có mô tả'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Giá: ${room['price']?.toString() ?? 'Không xác định'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                statusStyle['icon'],
                                                color: statusStyle['color'],
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Trạng thái: ${room['status'] ?? 'Không xác định'}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: statusStyle['color'],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Color(0xFF4EA0B7), size: 26),
                                          onPressed: () => _navigateToEditRoom(room),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red, size: 26),
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
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget để xây dựng các chip lọc trạng thái
  Widget _buildStatusFilterChip(String status, String label) {
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedFilter == status ? Colors.white : const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      selected: _selectedFilter == status,
      selectedColor: const Color(0xFF4EA0B7),
      backgroundColor: Colors.white,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = status;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF4EA0B7), width: 1.5),
      ),
      elevation: 3,
      pressElevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }
}