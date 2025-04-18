import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apehome_admin/screens/shop_details_screen.dart';

class ShopListScreen extends StatefulWidget {
  @override
  _ShopListScreenState createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  List<dynamic> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    setState(() => _isLoading = true);
    try {
      final token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.137:9090/api/v1/shops'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _shops = jsonDecode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách shop')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Shop'),
        backgroundColor: Color(0xFF4EA0B7),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chuyển đến trang tạo shop')),
                );
              },
              child: Text('Tạo Shop mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4EA0B7),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
                : _shops.isEmpty
                    ? Center(child: Text('Chưa có shop nào'))
                    : ListView.builder(
                        itemCount: _shops.length,
                        itemBuilder: (context, index) {
                          final shop = _shops[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: shop['imageFiles'] != null && shop['imageFiles'].isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        shop['imageFiles'][0]['url'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(Icons.store, size: 50),
                                      ),
                                    )
                                  : Icon(Icons.store, size: 50),
                              title: Text(shop['name'] ?? 'Không tên'),
                              subtitle: Text(shop['address'] ?? 'Không có địa chỉ'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ShopDetailsScreen(shopId: shop['id']),
                                  ),
                                );
                              },
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