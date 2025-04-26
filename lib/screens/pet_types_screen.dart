import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

class PetTypesScreen extends StatefulWidget {
  @override
  _PetTypesScreenState createState() => _PetTypesScreenState();
}

class _PetTypesScreenState extends State<PetTypesScreen> {
  List<dynamic> _petTypes = [];
  List<dynamic> _filteredPetTypes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _pageNo = 0;
  int _pageSize = 10;
  int _totalElements = 0;
  String _sortBy = 'name';
  String _sortDir = 'asc';

  @override
  void initState() {
    super.initState();
    _fetchPetTypes();
  }

  Future<void> _fetchPetTypes() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offNamed('/login');
        return;
      }

      final uri = Uri.parse(
          'http://192.168.41.175:9090/api/v1/pet-types');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _petTypes = data;
          _filteredPetTypes = data;
          _totalElements = data.length; 
        });
      } else {
        throw Exception('Lỗi khi tải danh sách loại thú cưng: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách loại thú cưng: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPetType(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offNamed('/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/pet-types');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Thành công', 'Đã thêm loại thú cưng mới',
            backgroundColor: Colors.green, colorText: Colors.white);
        _fetchPetTypes(); 
      } else {
        throw Exception('Lỗi khi thêm loại thú cưng: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm loại thú cưng: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _updatePetType(int id, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offNamed('/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/pet-types/$id');
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Thành công', 'Đã cập nhật loại thú cưng',
            backgroundColor: Colors.green, colorText: Colors.white);
        _fetchPetTypes(); 
      } else {
        throw Exception('Lỗi khi cập nhật loại thú cưng: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật loại thú cưng: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _deletePetType(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offNamed('/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/pet-types/$id');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Thành công', 'Đã xóa loại thú cưng',
            backgroundColor: Colors.green, colorText: Colors.white);
        _fetchPetTypes(); 
      } else {
        throw Exception('Lỗi khi xóa loại thú cưng: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa loại thú cưng: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredPetTypes = _petTypes
          .where((petType) =>
              petType['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Thêm loại thú cưng mới'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Nhập tên loại thú cưng',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4EA0B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addPetType(nameController.text);
                Navigator.pop(context);
              } else {
                Get.snackbar('Lỗi', 'Vui lòng nhập tên loại thú cưng',
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int id, String currentName) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sửa loại thú cưng'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Nhập tên loại thú cưng',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4EA0B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _updatePetType(id, nameController.text);
                Navigator.pop(context);
              } else {
                Get.snackbar('Lỗi', 'Vui lòng nhập tên loại thú cưng',
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: Text('Cập nhật', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa loại thú cưng "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              _deletePetType(id);
              Navigator.pop(context);
            },
            child: Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPetType(String name) {
    switch (name.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.air;
      case 'rabbit':
        return Icons.pets;
      case 'hamster':
        return Icons.pets;
      case 'capybara':
        return Icons.pets;
      default:
        return Icons.pets;
    }
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
                // AppBar
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
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.5)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Quản lý loại thú cưng',
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
                                          Icons.pets,
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
                                        hintText: 'Tìm kiếm loại thú cưng...',
                                        hintStyle:
                                            TextStyle(color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.2),
                                        prefixIcon:
                                            Icon(Icons.search, color: Colors.white),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                      onChanged: _onSearch,
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
                // Tổng quan
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: FadeInUp(
                      duration: Duration(milliseconds: 600),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4EA0B7), Color(0xFF3070B3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.3),
                                      child: Icon(Icons.pets,
                                          color: Colors.white, size: 26),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Tổng số loại thú cưng',
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
                                  _totalElements.toString(),
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
                    ),
                  ),
                ),
                // Danh sách Pet Types
                _filteredPetTypes.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Chưa có loại thú cưng nào',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final petType = _filteredPetTypes[index];
                            return FadeInUp(
                              duration: Duration(milliseconds: 700 + index * 100),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      radius: 24,
                                      child: Icon(
                                        _getIconForPetType(petType['name']),
                                        color: Color(0xFF4EA0B7),
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      petType['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    subtitle: Text(
                                      'ID: ${petType['id']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Color(0xFF4EA0B7)),
                                          onPressed: () {
                                            _showEditDialog(
                                                petType['id'], petType['name']);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _showDeleteDialog(
                                                petType['id'], petType['name']);
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Get.snackbar(
                                        'Thông tin',
                                        'Loại thú cưng: ${petType['name']} (ID: ${petType['id']})',
                                        backgroundColor: Colors.grey[800],
                                        colorText: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _filteredPetTypes.length,
                        ),
                      ),
                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF4EA0B7),
        onPressed: _showAddDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}