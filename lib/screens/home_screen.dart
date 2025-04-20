import 'package:apehome_admin/screens/room_types_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('userId');

      if (token == null) {
        token = await _storage.read(key: 'token');
        if (token != null) {
          await prefs.setString('token', token);
        }
      }

      if (userId == null) {
        userId = await _storage.read(key: 'userId');
        if (userId != null) {
          await prefs.setString('userId', userId);
        }
      }

      if (token == null || userId == null) {
        Get.offNamed('/login');
        return;
      }

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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm shop, đơn hàng...',
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white24,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onSubmitted: _onSearch,
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF4EA0B7).withOpacity(0.1),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSubheaderButton(
                  context: context,
                  label: 'My Shop',
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
                _buildSubheaderButton(
                  context: context,
                  label: 'My Booking',
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
                _buildSubheaderButton(
                  context: context,
                  label: 'Room Types',
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
              ],
            ),
          ),
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
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  label: 'Tổng số Shop', // Sửa từ title thành label
                                  value: _statistics['totalShops'].toString(),
                                  icon: Icons.store,
                                  backgroundColor: Colors.blue[50]!,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  label: 'Tổng số Đơn hàng', // Sửa từ title thành label
                                  value: _statistics['totalBookings'].toString(),
                                  icon: Icons.list_alt,
                                  backgroundColor: Colors.green[50]!,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildStatCard(
                            label: 'Đơn hàng đang chờ', // Sửa từ title thành label
                            value: _statistics['pendingBookings'].toString(),
                            icon: Icons.pending_actions,
                            backgroundColor: Colors.orange[50]!,
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
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
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
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: () {
        print('Button $label tapped');
        onPressed();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã nhấn vào $label')),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                      label,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4EA0B7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}