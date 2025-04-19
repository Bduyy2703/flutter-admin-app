import 'package:apehome_admin/screens/create_care_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CareServicesScreen extends StatefulWidget {
  final int shopId;

  const CareServicesScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  _CareServicesScreenState createState() => _CareServicesScreenState();
}

class _CareServicesScreenState extends State<CareServicesScreen> {
  List<dynamic> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/services/shops/${widget.shopId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Raw response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _services = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách dịch vụ: ${response.statusCode}')),
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

  Future<void> _deleteService(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/services/$serviceId');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _services.removeWhere((service) => service['id'] == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa dịch vụ thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa dịch vụ: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _navigateToCreateService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateCareServiceScreen(shopId: widget.shopId)),
    ).then((_) => _fetchServices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      appBar: AppBar(
        title: Text(
          'Danh Sách Dịch Vụ',
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
              onPressed: _navigateToCreateService,
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
                    'Tạo Dịch Vụ Mới',
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
                : _services.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có dịch vụ nào',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(15),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              title: Text(
                                service['type'] ?? 'Không tên',
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
                                    'Mô tả: ${service['description'] ?? 'Không có mô tả'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Giá: ${_formatPrice((service['price'] as num).toInt())} VND',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4EA0B7),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Color(0xFF4EA0B7)),
                                    onPressed: () {
                                      // TODO: Điều hướng đến màn hình chỉnh sửa dịch vụ
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Chuyển đến trang chỉnh sửa dịch vụ')),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteService(service['id']),
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