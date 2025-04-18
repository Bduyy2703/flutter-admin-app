import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ShopDetailsScreen extends StatefulWidget {
  final int shopId;

  ShopDetailsScreen({required this.shopId});

  @override
  _ShopDetailsScreenState createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  Map<String, dynamic> _shop = {};
  List<dynamic> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    setState(() => _isLoading = true);
    try {
      final token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Lấy thông tin shop
      final shopResponse = await http.get(
        Uri.parse('http://192.168.50.89:9090/api/v1/shops/${widget.shopId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (shopResponse.statusCode == 200) {
        _shop = jsonDecode(shopResponse.body);
      }

      // Lấy danh sách room
      final roomsResponse = await http.get(
        Uri.parse('http://192.168.50.89:9090/api/v1/rooms/shops/${widget.shopId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (roomsResponse.statusCode == 200) {
        _rooms = jsonDecode(roomsResponse.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải chi tiết shop: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tạo Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Tên Room')),
            TextField(decoration: InputDecoration(labelText: 'Giá')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Gọi API POST /api/v1/rooms ở đây
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tạo room thành công')),
              );
              Navigator.pop(context);
            },
            child: Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Shop'),
        backgroundColor: Color(0xFF4EA0B7),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin shop
                  Text(
                    'Thông tin Shop',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tên: ${_shop['name'] ?? 'Không tên'}'),
                          Text('Địa chỉ: ${_shop['address'] ?? 'Không có địa chỉ'}'),
                          Text('Trạng thái: ${_shop['verified'] == true ? 'Đã xác minh' : 'Chưa xác minh'}'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Rooms
                  Text(
                    'Danh sách Room',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _showCreateRoomDialog,
                    child: Text('Tạo Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4EA0B7),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 8),
                  _rooms.isEmpty
                      ? Text('Chưa có room nào', style: TextStyle(color: Colors.grey))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _rooms.length,
                          itemBuilder: (context, index) {
                            final room = _rooms[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(room['name'] ?? 'Room không tên'),
                                subtitle: Text('Giá: ${room['price']?.toString() ?? '0'}'),
                              ),
                            );
                          },
                        ),

                  // Care-Services placeholder
                  SizedBox(height: 24),
                  Text(
                    'Danh sách Care-Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Chưa có dịch vụ chăm sóc', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
    );
  }
}