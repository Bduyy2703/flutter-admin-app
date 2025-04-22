// import 'package:apehome_admin/screens/room_types_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:apehome_admin/providers/auth_providers.dart';
// import 'package:apehome_admin/screens/login_screen.dart';
// import 'package:apehome_admin/screens/shop_list_screen.dart';
// import 'package:apehome_admin/screens/booking_screen.dart';
// import 'package:apehome_admin/screens/setting_screen.dart';
// import 'package:animate_do/animate_do.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Map<String, dynamic> _statistics = {'totalShops': 0, 'totalBookings': 0, 'pendingBookings': 0};
//   bool _isLoading = false;
//   String _searchQuery = '';
//   final _storage = const FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     _checkAuth();
//   }

//   Future<void> _checkAuth() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');
//       String? userId = prefs.getString('userId');

//       if (token == null) {
//         token = await _storage.read(key: 'token');
//         if (token != null) {
//           await prefs.setString('token', token);
//         }
//       }

//       if (userId == null) {
//         userId = await _storage.read(key: 'userId');
//         if (userId != null) {
//           await prefs.setString('userId', userId);
//         }
//       }

//       if (token == null || userId == null) {
//         Get.offNamed('/login');
//         return;
//       }

//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       if (!authProvider.isAuthenticated) {
//         await authProvider.login(token);
//       }
//     } catch (e) {
//       Get.snackbar('Lỗi', 'Không thể xác thực: $e', backgroundColor: Colors.red, colorText: Colors.white);
//       Get.offNamed('/login');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _logout() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.logout();
//     await _storage.delete(key: 'token');
//     await _storage.delete(key: 'userId');
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('userId');
//     Get.offNamed('/login');
//   }

//   void _onSearch(String query) {
//     setState(() => _searchQuery = query);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Tìm kiếm: $query')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // AppBar cải tiến
//           SliverAppBar(
//             expandedHeight: 200.0,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Hình nền mờ
//                     Positioned.fill(
//                       child: Opacity(
//                         opacity: 0.1,
//                         child: Image.asset(
//                           'assets/background.png', // Thêm hình nền nếu có
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) => Container(),
//                         ),
//                       ),
//                     ),
//                     // Nội dung trong AppBar
//                     SafeArea(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'ApeHome Admin',
//                                   style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     letterSpacing: 1.2,
//                                   ),
//                                 ),
//                                 CircleAvatar(
//                                   radius: 20,
//                                   backgroundColor: Colors.white,
//                                   child: Icon(
//                                     Icons.person,
//                                     color: Color(0xFF4EA0B7),
//                                     size: 28,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//                             FadeInDown(
//                               duration: Duration(milliseconds: 500),
//                               child: TextField(
//                                 decoration: InputDecoration(
//                                   hintText: 'Tìm kiếm shop, đơn hàng...',
//                                   hintStyle: TextStyle(color: Colors.white70),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(30),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.white.withOpacity(0.2),
//                                   prefixIcon: Icon(Icons.search, color: Colors.white),
//                                   contentPadding: EdgeInsets.symmetric(vertical: 0),
//                                 ),
//                                 style: TextStyle(color: Colors.white),
//                                 onSubmitted: _onSearch,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Nội dung chính
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 // Subheader Buttons
//                 FadeInUp(
//                   duration: Duration(milliseconds: 600),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _buildSubheaderButton(
//                             context: context,
//                             label: 'My Shop',
//                             icon: Icons.store,
//                             onPressed: () {
//                               print('Navigating to /shops');
//                               try {
//                                 Navigator.of(context).pushNamed('/shops');
//                               } catch (e) {
//                                 print('Error navigating to /shops: $e');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Không thể chuyển đến My Shop: $e')),
//                                 );
//                               }
//                             },
//                           ),
//                           SizedBox(width: 12),
//                           _buildSubheaderButton(
//                             context: context,
//                             label: 'My Booking',
//                             icon: Icons.list_alt,
//                             onPressed: () {
//                               print('Navigating to /bookings');
//                               try {
//                                 Navigator.of(context).pushNamed('/bookings');
//                               } catch (e) {
//                                 print('Error navigating to /bookings: $e');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Không thể chuyển đến My Booking: $e')),
//                                 );
//                               }
//                             },
//                           ),
//                           SizedBox(width: 12),
//                           _buildSubheaderButton(
//                             context: context,
//                             label: 'Room Types',
//                             icon: Icons.room_preferences,
//                             onPressed: () {
//                               print('Navigating to /room-types');
//                               try {
//                                 Navigator.of(context).pushNamed('/room-types');
//                               } catch (e) {
//                                 print('Error navigating to /room-types: $e');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Không thể chuyển đến Room Types: $e')),
//                                 );
//                               }
//                             },
//                           ),
//                           SizedBox(width: 12),
//                           _buildSubheaderButton(
//                             context: context,
//                             label: 'Pet Type',
//                             icon: Icons.pets,
//                             onPressed: () {
//                               print('Navigating to /pet-types');
//                               try {
//                                 Navigator.of(context).pushNamed('/pet-types');
//                               } catch (e) {
//                                 print('Error navigating to /pet-types: $e');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Không thể chuyển đến Pet Type: $e')),
//                                 );
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Tổng quan
//                 Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       FadeInLeft(
//                         duration: Duration(milliseconds: 700),
//                         child: Text(
//                           'Tổng quan',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2D2D2D),
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       FadeInUp(
//                         duration: Duration(milliseconds: 800),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: _buildStatCard(
//                                 label: 'Tổng số Shop',
//                                 value: _statistics['totalShops'].toString(),
//                                 icon: Icons.store,
//                                 gradientColors: [Colors.blue[300]!, Colors.blue[600]!],
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             Expanded(
//                               child: _buildStatCard(
//                                 label: 'Tổng số Đơn hàng',
//                                 value: _statistics['totalBookings'].toString(),
//                                 icon: Icons.list_alt,
//                                 gradientColors: [Colors.green[300]!, Colors.green[600]!],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       FadeInUp(
//                         duration: Duration(milliseconds: 900),
//                         child: _buildStatCard(
//                           label: 'Đơn hàng đang chờ',
//                           value: _statistics['pendingBookings'].toString(),
//                           icon: Icons.pending_actions,
//                           gradientColors: [Colors.orange[300]!, Colors.orange[600]!],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.contact_support),
//             label: 'Contact',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.logout),
//             label: 'Logout',
//           ),
//         ],
//         selectedItemColor: Color(0xFF4EA0B7),
//         unselectedItemColor: Colors.grey,
//         backgroundColor: Colors.white,
//         elevation: 12,
//         type: BottomNavigationBarType.fixed,
//         selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
//         unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
//         onTap: (index) {
//           if (index == 0) {
//             print('Navigating to /settings');
//             try {
//               Navigator.of(context).pushNamed('/settings');
//             } catch (e) {
//               print('Error navigating to /settings: $e');
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Không thể chuyển đến Settings: $e')),
//               );
//             }
//           } else if (index == 1) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Liên hệ hỗ trợ')),
//             );
//           } else if (index == 2) {
//             _logout();
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildSubheaderButton({
//     required BuildContext context,
//     required String label,
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         print('Button $label tapped');
//         onPressed();
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               offset: Offset(0, 4),
//               blurRadius: 8,
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required String label,
//     required String value,
//     required IconData icon,
//     required List<Color> gradientColors,
//   }) {
//     return Card(
//       elevation: 6,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradientColors,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: InkWell(
//           onTap: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Đã nhấn vào $label')),
//             );
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       child: Icon(icon, color: Colors.white, size: 24),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         label,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:apehome_admin/screens/room_types_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apehome_admin/providers/auth_providers.dart';
import 'package:apehome_admin/screens/login_screen.dart';
import 'package:apehome_admin/screens/shop_list_screen.dart';
import 'package:apehome_admin/screens/booking_screen.dart';
import 'package:apehome_admin/screens/setting_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _statistics = {
    'totalShops': 0,
    'totalBookings': 0,
    'pendingBookings': 0,
    'totalRevenue': 0.0,
    'bookingStatuses': {'PENDING': 0, 'COMPLETED': 0, 'CANCELLED': 0},
  };
  List<Map<String, dynamic>> _topShops = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

 Future<void> _checkAuth() async {
  setState(() => _isLoading = true);
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      token = await _storage.read(key: 'token');
      if (token != null) {
        await prefs.setString('token', token);
      }
    }

    if (token == null) {
      Get.offNamed('/login');
      return;
    }

    // Decode token để lấy userId
    String? userId;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['userId']?.toString();
      // Giả sử userId nằm trong payload với key 'userId'
      // Nếu key khác (ví dụ 'sub', 'id'), bạn cần thay đổi key tương ứng
      if (userId == null) {
        throw Exception('Không tìm thấy userId trong token');
      }
    } catch (e) {
      print('Lỗi khi decode token: $e');
      Get.snackbar('Lỗi', 'Không thể decode token: $e', backgroundColor: Colors.red, colorText: Colors.white);
      Get.offNamed('/login');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      await authProvider.login(token);
    }

    // Sau khi xác thực thành công, gọi API để lấy thống kê
    await _fetchStatistics(userId);
  } catch (e) {
    Get.snackbar('Lỗi', 'Không thể xác thực: $e', backgroundColor: Colors.red, colorText: Colors.white);
    Get.offNamed('/login');
  } finally {
    setState(() => _isLoading = false);
  }
}
  Future<void> _fetchStatistics(String userId) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Get.offNamed('/login');
        return;
      }

      // 1. Lấy danh sách Shop theo userId
      final shopUri = Uri.parse('http://192.168.41.175:9090/api/v1/shops/users/$userId?pageNo=0&pageSize=100&sortBy=id&sortDir=asc');
      final shopResponse = await http.get(
        shopUri,
        headers: {'Authorization': 'Bearer $token'},
      );

      int totalShops = 0;
      List<dynamic> shops = [];
      if (shopResponse.statusCode == 200) {
        final decodedBody = utf8.decode(shopResponse.bodyBytes);
        final data = jsonDecode(decodedBody);
        totalShops = data['totalElements'];
        shops = data['content'];
      } else {
        throw Exception('Lỗi khi tải danh sách shop: ${shopResponse.statusCode}');
      }

      // 2. Lấy danh sách Đơn hàng từ tất cả các Shop
      int totalBookings = 0;
      int pendingBookings = 0;
      double totalRevenue = 0.0;
      Map<String, int> bookingStatuses = {'PENDING': 0, 'COMPLETED': 0, 'CANCELLED': 0};
      List<Map<String, dynamic>> shopBookingCounts = [];

      for (var shop in shops) {
        final shopId = shop['id'];
        final bookingUri = Uri.parse('http://192.168.41.175:9090/api/v1/bookings/shops/$shopId?pageNo=0&pageSize=100&sortBy=id&sortDir=asc');
        final bookingResponse = await http.get(
          bookingUri,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (bookingResponse.statusCode == 200) {
          final decodedBody = utf8.decode(bookingResponse.bodyBytes);
          final data = jsonDecode(decodedBody);
          final bookings = data['content'] as List;
          totalBookings += bookings.length;
          pendingBookings += bookings.where((booking) => booking['status'] == 'PENDING').length;
          totalRevenue += bookings.fold(0.0, (sum, booking) => sum + (booking['totalPrice']?.toDouble() ?? 0.0));

          // Đếm số đơn hàng theo trạng thái
          for (var booking in bookings) {
            final status = booking['status'] as String;
            if (bookingStatuses.containsKey(status)) {
              bookingStatuses[status] = bookingStatuses[status]! + 1;
            }
          }

          // Lưu số lượng đơn hàng của shop để tìm top shop
          shopBookingCounts.add({
            'shopId': shopId,
            'shopName': shop['name'],
            'bookingCount': bookings.length,
          });
        } else {
          print('Lỗi khi tải danh sách đơn hàng cho shop $shopId: ${bookingResponse.statusCode}');
        }
      }

      // Sắp xếp để lấy top 3 shop có nhiều đơn hàng nhất
      shopBookingCounts.sort((a, b) => b['bookingCount'].compareTo(a['bookingCount']));
      final topShops = shopBookingCounts.take(3).toList();

      // Cập nhật thống kê
      setState(() {
        _statistics = {
          'totalShops': totalShops,
          'totalBookings': totalBookings,
          'pendingBookings': pendingBookings,
          'totalRevenue': totalRevenue,
          'bookingStatuses': bookingStatuses,
        };
        _topShops = topShops;
      });
    } catch (e) {
      print('Lỗi khi lấy thống kê: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải thống kê. Vui lòng thử lại!')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    Get.offNamed('/login');
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tìm kiếm: $query')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4EA0B7)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // AppBar cải tiến
                SliverAppBar(
                  expandedHeight: 220.0,
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
                      child: Stack(
                        children: [
                          // Hiệu ứng mờ
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.5)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          // Nội dung trong AppBar
                          SafeArea(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ApeHome Admin',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.person,
                                          color: Color(0xFF4EA0B7),
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  FadeInDown(
                                    duration: Duration(milliseconds: 500),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Tìm kiếm shop, đơn hàng...',
                                        hintStyle: TextStyle(color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: BorderSide(color: Colors.white, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: BorderSide(color: Colors.white, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.2),
                                        prefixIcon: Icon(Icons.search, color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                      onSubmitted: _onSearch,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Nội dung chính
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Subheader Buttons
                      FadeInUp(
                        duration: Duration(milliseconds: 600),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSubheaderButton(
                                  context: context,
                                  label: 'My Shop',
                                  icon: Icons.store,
                                  onPressed: () {
                                    print('Navigating to /shops');
                                    try {
                                      Navigator.of(context).pushNamed('/shops');
                                    } catch (e) {
                                      print('Error navigating to /shops: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Không thể chuyển đến My Shop: $e')),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(width: 12),
                                _buildSubheaderButton(
                                  context: context,
                                  label: 'My Booking',
                                  icon: Icons.list_alt,
                                  onPressed: () {
                                    print('Navigating to /bookings');
                                    try {
                                      Navigator.of(context).pushNamed('/bookings');
                                    } catch (e) {
                                      print('Error navigating to /bookings: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Không thể chuyển đến My Booking: $e')),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(width: 12),
                                _buildSubheaderButton(
                                  context: context,
                                  label: 'Room Types',
                                  icon: Icons.room_preferences,
                                  onPressed: () {
                                    print('Navigating to /room-types');
                                    try {
                                      Navigator.of(context).pushNamed('/room-types');
                                    } catch (e) {
                                      print('Error navigating to /room-types: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Không thể chuyển đến Room Types: $e')),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(width: 12),
                                _buildSubheaderButton(
                                  context: context,
                                  label: 'Pet Type',
                                  icon: Icons.pets,
                                  onPressed: () {
                                    print('Navigating to /pet-types');
                                    try {
                                      Get.toNamed('/pet-types');
                                    } catch (e) {
                                      print('Error navigating to /pet-types: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Không thể chuyển đến Pet Type: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Thông báo nhanh
                      if (_statistics['pendingBookings'] > 0)
                        FadeInUp(
                          duration: Duration(milliseconds: 700),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/bookings');
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.red[300]!, Colors.red[600]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.white, size: 28),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Có ${_statistics['pendingBookings']} đơn hàng đang chờ xử lý',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Tổng quan
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInLeft(
                              duration: Duration(milliseconds: 700),
                              child: Text(
                                'Tổng quan',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            FadeInUp(
                              duration: Duration(milliseconds: 800),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'Tổng số Shop',
                                      value: _statistics['totalShops'].toString(),
                                      icon: Icons.store,
                                      gradientColors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'Tổng số Đơn hàng',
                                      value: _statistics['totalBookings'].toString(),
                                      icon: Icons.list_alt,
                                      gradientColors: [Colors.green[400]!, Colors.green[700]!],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            FadeInUp(
                              duration: Duration(milliseconds: 900),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'Đơn hàng đang chờ',
                                      value: _statistics['pendingBookings'].toString(),
                                      icon: Icons.pending_actions,
                                      gradientColors: [Colors.orange[400]!, Colors.orange[700]!],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      label: 'Tổng doanh thu',
                                      value: '${_statistics['totalRevenue'].toStringAsFixed(0)} VND',
                                      icon: Icons.monetization_on,
                                      gradientColors: [Colors.purple[400]!, Colors.purple[700]!],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Biểu đồ phân bố đơn hàng
                      FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phân bố trạng thái đơn hàng',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.orange,
                                        value: _statistics['bookingStatuses']['PENDING'].toDouble(),
                                        title: 'Chưa xác nhận',
                                        radius: 80,
                                        titleStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: _statistics['bookingStatuses']['COMPLETED'].toDouble(),
                                        title: 'Đã hoàn thành',
                                        radius: 80,
                                        titleStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: _statistics['bookingStatuses']['CANCELLED'].toDouble(),
                                        title: 'Đã hủy',
                                        radius: 80,
                                        titleStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Top Shop
                      FadeInUp(
                        duration: Duration(milliseconds: 1100),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Shop hoạt động',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 16),
                              if (_topShops.isEmpty)
                                Center(
                                  child: Text(
                                    'Chưa có shop nào nổi bật',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                )
                              else
                                Column(
                                  children: _topShops.map((shop) {
                                    return Card(
                                      elevation: 6,
                                      margin: EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue[100],
                                          radius: 24,
                                          child: Icon(
                                            Icons.store,
                                            color: Color(0xFF4EA0B7),
                                            size: 28,
                                          ),
                                        ),
                                        title: Text(
                                          shop['shopName'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D2D2D),
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Số đơn hàng: ${shop['bookingCount']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward,
                                          color: Color(0xFF4EA0B7),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(context, '/shops');
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_support),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        selectedItemColor: Color(0xFF4EA0B7),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        onTap: (index) {
          if (index == 0) {
            print('Navigating to /settings');
            try {
              Navigator.of(context).pushNamed('/settings');
            } catch (e) {
              print('Error navigating to /settings: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Không thể chuyển đến Settings: $e')),
              );
            }
          } else if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Liên hệ hỗ trợ')),
            );
          } else if (index == 2) {
            _logout();
          }
        },
      ),
    );
  }

  Widget _buildSubheaderButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        print('Button $label tapped');
        onPressed();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã nhấn vào $label')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}