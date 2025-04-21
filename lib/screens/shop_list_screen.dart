import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:apehome_admin/screens/shop_details.dart';
import 'package:apehome_admin/screens/create_shop_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

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
        _userId = decodedToken['userId']?.toString() ?? decodedToken['sub']?.toString();

        print('Decoded Token: $decodedToken');
        print('Extracted userId: $_userId');
      } catch (e) {
        print('Error decoding token: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi giải mã token: $e')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (_userId == null || _userId!.isEmpty) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse(
        'http://192.168.41.175:9090/api/v1/shops/users/$_userId',
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
        print('Raw response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        _shops = (data['content'] ?? data).map((shop) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
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
      body: CustomScrollView(
        slivers: [
          // AppBar cải tiến
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Danh Sách Shop',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Quản lý các cửa hàng của bạn',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
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
          // Nội dung chính
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Nút Tạo Shop Mới
                FadeInDown(
                  duration: Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ElevatedButton(
                      onPressed: _navigateToCreateShop,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.black26,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Tạo Shop Mới',
                                style: TextStyle(
                                  fontSize: 16,
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
                // Danh sách shop
                _isLoading
                    ? Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4EA0B7),
                          ),
                        ),
                      )
                    : _shops.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.store_outlined,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Chưa có shop nào',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16),
                            itemCount: _shops.length,
                            itemBuilder: (context, index) {
                              final shop = _shops[index];
                              final shopImage = shop['imageFiles'] != null && shop['imageFiles'].isNotEmpty
                                  ? shop['imageFiles'][0]['url']
                                  : 'https://i.imgur.com/1tMFzp8.png';

                              final lowestPrice = shop['services'] != null && shop['services'].isNotEmpty
                                  ? (shop['services'] as List)
                                      .map((service) => (service['price'] as num).toInt())
                                      .reduce((a, b) => a < b ? a : b)
                                  : null;

                              final serviceTypes = shop['services'] != null && shop['services'].isNotEmpty
                                  ? (shop['services'] as List)
                                      .map((service) => service['type'] as String)
                                      .toSet()
                                      .toList()
                                  : [];

                              return FadeInUp(
                                duration: Duration(milliseconds: 400 + (index * 100)),
                                child: GestureDetector(
                                  onTap: () => _navigateToShopDetails(shop['id']),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: Offset(0, 4),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            imageUrl: shopImage,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  color: Color(0xFF4EA0B7),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
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
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                shop['name'] ?? 'Không tên',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2D2D2D),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Color(0xFF4EA0B7),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Địa chỉ: ${shop['address'] ?? 'Không có địa chỉ'}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.description,
                                                    size: 16,
                                                    color: Color(0xFF4EA0B7),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Mô tả: ${shop['description'] ?? 'Không có mô tả'}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              if (serviceTypes.isNotEmpty)
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 6,
                                                  children: serviceTypes.map((type) {
                                                    return Chip(
                                                      label: Text(
                                                        type,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      backgroundColor: Color(0xFF4EA0B7),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    );
                                                  }).toList(),
                                                ),
                                              SizedBox(height: 8),
                                              if (lowestPrice != null)
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.monetization_on,
                                                      size: 16,
                                                      color: Color(0xFF4EA0B7),
                                                    ),
                                                    SizedBox(width: 4),
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
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}