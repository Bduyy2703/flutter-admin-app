import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Thêm import GetX
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apehome_admin/providers/auth_providers.dart';
import 'package:apehome_admin/screens/login_screen.dart';
import 'package:apehome_admin/screens/shop_list_screen.dart';
import 'package:apehome_admin/screens/booking_screen.dart';
import 'package:apehome_admin/screens/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _statistics = {'totalShops': 0, 'totalBookings': 0, 'pendingBookings': 0};
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
      // Kiểm tra token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // Nếu không có trong SharedPreferences, thử lấy từ FlutterSecureStorage
      if (token == null) {
        token = await _storage.read(key: 'token');
        if (token != null) {
          await prefs.setString('token', token); // Đồng bộ hóa
        }
      }

      if (token == null) {
        Get.offNamed('/login');
        return;
      }

      // Cập nhật AuthProvider nếu cần
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        await authProvider.login(token);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xác thực: $e', backgroundColor: Colors.red, colorText: Colors.white);
      Get.offNamed('/login');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    await _storage.delete(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
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
      appBar: AppBar(
        backgroundColor: Color(0xFF4EA0B7),
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm shop, đơn hàng...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onSubmitted: _onSearch,
        ),
      ),
      body: Column(
        children: [
          // Subheader
          Container(
            color: Color(0xFF4EA0B7).withOpacity(0.1),
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSubheaderButton(
                  label: 'My Shop',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ShopListScreen()),
                  ),
                ),
                _buildSubheaderButton(
                  label: 'My Booking',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookingListScreen()),
                  ),
                ),
              ],
            ),
          ),
          // Nội dung chính
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
                : RefreshIndicator(
                    onRefresh: _checkAuth,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng quan',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Tổng số Shop',
                                  value: _statistics['totalShops'].toString(),
                                  icon: Icons.store,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Tổng số Đơn hàng',
                                  value: _statistics['totalBookings'].toString(),
                                  icon: Icons.list_alt,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildStatCard(
                            title: 'Đơn hàng đang chờ',
                            value: _statistics['pendingBookings'].toString(),
                            icon: Icons.pending_actions,
                          ),
                        ],
                      ),
                    ),
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
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
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

  Widget _buildSubheaderButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4EA0B7),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF4EA0B7), size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4EA0B7)),
            ),
          ],
        ),
      ),
    );
  }
}