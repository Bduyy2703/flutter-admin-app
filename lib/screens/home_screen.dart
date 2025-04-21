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
import 'package:animate_do/animate_do.dart';

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
      body: CustomScrollView(
        slivers: [
          // AppBar cải tiến
          SliverAppBar(
            expandedHeight: 200.0,
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
                    // Hình nền mờ
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/background.png', // Thêm hình nền nếu có
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(),
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
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF4EA0B7),
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            FadeInDown(
                              duration: Duration(milliseconds: 500),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm shop, đơn hàng...',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  prefixIcon: Icon(Icons.search, color: Colors.white),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
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
                                Navigator.of(context).pushNamed('/pet-types');
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
                                gradientColors: [Colors.blue[300]!, Colors.blue[600]!],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                label: 'Tổng số Đơn hàng',
                                value: _statistics['totalBookings'].toString(),
                                icon: Icons.list_alt,
                                gradientColors: [Colors.green[300]!, Colors.green[600]!],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeInUp(
                        duration: Duration(milliseconds: 900),
                        child: _buildStatCard(
                          label: 'Đơn hàng đang chờ',
                          value: _statistics['pendingBookings'].toString(),
                          icon: Icons.pending_actions,
                          gradientColors: [Colors.orange[300]!, Colors.orange[600]!],
                        ),
                      ),
                    ],
                  ),
                ),
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
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
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
      elevation: 6,
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
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
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