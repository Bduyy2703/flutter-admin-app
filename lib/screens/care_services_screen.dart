import 'package:apehome_admin/screens/create_care_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

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
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/services/shops/${widget.shopId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Lấy danh sách dịch vụ - Dữ liệu thô: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _services = data['content']; // Lấy danh sách từ key "content"
        });
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi tải danh sách dịch vụ: ${response.statusCode}');
      }
    } catch (e) {
      print('Lấy danh sách dịch vụ - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách dịch vụ. Vui lòng thử lại!')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(int serviceId, String serviceType) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa dịch vụ "$serviceType"?'),
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

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/services/$serviceId');
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
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi xóa dịch vụ: ${response.statusCode}');
      }
    } catch (e) {
      print('Xóa dịch vụ - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa dịch vụ. Vui lòng thử lại!')),
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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'spa':
        return Colors.pink[100]!;
      case 'vet':
        return Colors.green[100]!;
      case 'vaccine':
        return Colors.blue[100]!;
      case 'hotel':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      body: RefreshIndicator(
        onRefresh: _fetchServices,
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
                  'Danh Sách Dịch Vụ',
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
                    onPressed: _navigateToCreateService,
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
                  : _services.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.pets, size: 50, color: Colors.grey[400]),
                                SizedBox(height: 8),
                                Text(
                                  'Chưa có dịch vụ nào',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: List.generate(
                              _services.length,
                              (index) {
                                final service = _services[index];
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
                                          backgroundColor: _getTypeColor(service['type']),
                                          child: Icon(
                                            Icons.pets,
                                            color: Color(0xFF4EA0B7),
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          service['type']?.toUpperCase() ?? 'Không tên',
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
                                              'Tên: ${service['name'] ?? 'Không tên'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Mô tả: ${service['description'] ?? 'Không có mô tả'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                                              onPressed: () => _deleteService(
                                                service['id'],
                                                service['name'] ?? 'Không tên',
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
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}