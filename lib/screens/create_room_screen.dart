import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

class CreateRoomScreen extends StatefulWidget {
  final int shopId;

  const CreateRoomScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(); // Thêm controller cho price
  final _signController = TextEditingController();  // Thêm controller cho sign
  final _codesController = TextEditingController();
  String? _selectedStatus;
  int? _selectedRoomTypeId;
  List<dynamic> _roomTypes = [];
  bool _isLoading = false;
  bool _isFetchingRoomTypes = true;

  final List<String> _statusOptions = ['AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'CLOSED'];

  @override
  void initState() {
    super.initState();
    _fetchRoomTypes();
  }

  Future<void> _fetchRoomTypes() async {
    setState(() => _isFetchingRoomTypes = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/room-types');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _roomTypes = data;
          if (_roomTypes.isNotEmpty) {
            _selectedRoomTypeId = _roomTypes[0]['id'];
          }
        });
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi tải danh sách loại phòng: ${response.statusCode}');
      }
    } catch (e) {
      print('Lấy danh sách loại phòng - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách loại phòng. Vui lòng thử lại!')),
      );
    } finally {
      setState(() => _isFetchingRoomTypes = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose(); // Dispose controller mới
    _signController.dispose();  // Dispose controller mới
    _codesController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final codes = _codesController.text.split(',').map((code) => code.trim()).toList();

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/rooms');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text), // Thêm price
          'status': _selectedStatus!.toLowerCase(),
          'sign': _signController.text, // Thêm sign
          'shopId': widget.shopId,
          'roomTypeId': _selectedRoomTypeId,
          'codes': codes,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo phòng thành công')),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi tạo phòng: ${response.statusCode}');
      }
    } catch (e) {
      print('Tạo phòng - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tạo phòng. Vui lòng thử lại!')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      body: CustomScrollView(
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
                'Tạo Phòng Mới',
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
              padding: const EdgeInsets.all(16.0),
              child: _isFetchingRoomTypes
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInUp(
                            duration: Duration(milliseconds: 500),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Tên Phòng',
                                prefixIcon: Icon(Icons.room, color: Color(0xFF4EA0B7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF4EA0B7)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tên phòng';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInUp(
                            duration: Duration(milliseconds: 600),
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Mô Tả',
                                prefixIcon: Icon(Icons.description, color: Color(0xFF4EA0B7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF4EA0B7)),
                                ),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mô tả';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInUp(
                            duration: Duration(milliseconds: 650),
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Giá Phòng',
                                prefixIcon: Icon(Icons.attach_money, color: Color(0xFF4EA0B7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF4EA0B7)),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập giá phòng';
                                }
                                try {
                                  double.parse(value);
                                  return null;
                                } catch (e) {
                                  return 'Giá phòng phải là một số hợp lệ';
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInUp(
                            duration: Duration(milliseconds: 700),
                            child: TextFormField(
                              controller: _signController,
                              decoration: InputDecoration(
                                labelText: 'Dấu Hiệu (Sign)',
                                prefixIcon: Icon(Icons.label, color: Color(0xFF4EA0B7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF4EA0B7)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập dấu hiệu';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInUp(
                            duration: Duration(milliseconds: 750),
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Trạng Thái',
                                prefixIcon: Icon(Icons.info, color: Color(0xFF4EA0B7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF4EA0B7)),
                                ),
                              ),
                              items: _statusOptions.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Vui lòng chọn trạng thái';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            child: DropdownButtonFormField<int>(
                              value: _selectedRoomTypeId,
                              decoration: InputDecoration(
                                labelText: 'Loại Phòng',
                                prefixIcon: Icon(Icons.category, color: Color(0xFF4EA0B7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF4EA0B7)),
                                ),
                              ),
                              items: _roomTypes.map((roomType) {
                                return DropdownMenuItem<int>(
                                  value: roomType['id'],
                                  child: Text(roomType['name'] ?? 'Không tên'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoomTypeId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Vui lòng chọn loại phòng';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInUp(
                            duration: Duration(milliseconds: 900),
                            child: TextFormField(
                              controller: _codesController,
                              decoration: InputDecoration(
                                labelText: 'Mã Phòng (phân cách bởi dấu phẩy)',
                                prefixIcon: Icon(Icons.code, color: Color(0xFF4EA0B7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF4EA0B7)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập ít nhất một mã phòng';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeInUp(
                            duration: Duration(milliseconds: 1000),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _createRoom,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                    child: Text(
                                      _isLoading ? 'Đang Tạo...' : 'Tạo Phòng',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}