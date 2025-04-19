import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:apehome_admin/screens/shop_details.dart';
import 'package:apehome_admin/screens/create_shop_screen.dart';

class ShopListScreen extends StatefulWidget {
  @override
  _ShopListScreenState createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  List<dynamic> _shops = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndShops();
  }

  Future<void> _fetchUserIdAndShops() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        _userId =
            decodedToken['userId']?.toString() ??
            decodedToken['sub']?.toString();

        print('Decoded Token: $decodedToken');
        print('Extracted userId: $_userId');
      } catch (e) {
        print('Error decoding token: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi giải mã token: $e')));
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (_userId == null || _userId!.isEmpty) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse(
        'http://192.168.1.29:9090/api/v1/shops/users/$_userId',
      ).replace(
        queryParameters: {
          'pageNo': '0',
          'pageSize': '10',
          'sortBy': 'id',
          'sortDir': 'asc',
        },
      );

      print('Calling URI: $uri');
      print('Token: $token');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // In dữ liệu thô để kiểm tra
        print('Raw response body: ${response.body}');

        // Giải mã dữ liệu dạng UTF-8 từ raw bytes
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        _shops =
            (data['content'] ?? data).map((shop) {
              return {
                'id': shop['id'],
                'name': shop['name'] ?? 'Không tên',
                'address': shop['address'] ?? 'Không có địa chỉ',
                'description': shop['description'] ?? 'Không có mô tả',
                'imageFiles': shop['imageFiles'],
                'services': shop['services'],
              };
            }).toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi khi tải danh sách shop: ${response.statusCode} - ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _navigateToShopDetails(int shopId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopDetailsScreen(shopId: shopId)),
    );
  }

  void _navigateToCreateShop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateShopScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      appBar: AppBar(
        title: Text(
          'Danh Sách Shop',
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
              onPressed: _navigateToCreateShop,
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
                    'Tạo Shop Mới',
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
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4EA0B7),
                      ),
                    )
                    : _shops.isEmpty
                    ? Center(
                      child: Text(
                        'Chưa có shop nào',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(15),
                      itemCount: _shops.length,
                      itemBuilder: (context, index) {
                        final shop = _shops[index];
                        final shopImage =
                            shop['imageFiles'] != null &&
                                    shop['imageFiles'].isNotEmpty
                                ? shop['imageFiles'][0]['url']
                                : 'https://i.imgur.com/1tMFzp8.png';

                        final lowestPrice =
                            shop['services'] != null &&
                                    shop['services'].isNotEmpty
                                ? (shop['services'] as List)
                                    .map(
                                      (service) =>
                                          (service['price'] as num).toInt(),
                                    )
                                    .reduce((a, b) => a < b ? a : b)
                                : null;

                        final serviceTypes =
                            shop['services'] != null &&
                                    shop['services'].isNotEmpty
                                ? (shop['services'] as List)
                                    .map((service) => service['type'] as String)
                                    .toSet()
                                    .toList()
                                : [];

                        return GestureDetector(
                          onTap: () => _navigateToShopDetails(shop['id']),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    shopImage,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.store,
                                                size: 50,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop['name'] ?? 'Không tên',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D2D2D),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Địa chỉ: ${shop['address'] ?? 'Không có địa chỉ'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Mô tả: ${shop['description'] ?? 'Không có mô tả'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      if (serviceTypes.isNotEmpty)
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children:
                                              serviceTypes.map((type) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF4EA0B7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    type,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      SizedBox(height: 8),
                                      if (lowestPrice != null)
                                        Text(
                                          'Giá từ ${_formatPrice(lowestPrice)} VND',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4EA0B7),
                                          ),
                                        ),
                                    ],
                                  ),
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
