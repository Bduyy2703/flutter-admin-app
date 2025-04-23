import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CreateShopScreen extends StatefulWidget {
  @override
  _CreateShopScreenState createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createShop() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _bankNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ các trường bắt buộc')),
      );
      return;
    }

    final phonePattern = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phonePattern.hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số điện thoại phải có 10-15 chữ số và có thể bắt đầu bằng "+"')),
      );
      return;
    }

    final accountNumberPattern = RegExp(r'^[0-9]{10,20}$');
    if (!accountNumberPattern.hasMatch(_accountNumberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số tài khoản phải có 10-20 chữ số')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token is null, redirecting to login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy token, vui lòng đăng nhập lại')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['userId']?.toString() ?? '';

      if (userId.isEmpty) {
        print('userId is empty, redirecting to login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy userId, vui lòng đăng nhập lại')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      int parsedUserId;
      try {
        parsedUserId = int.parse(userId);
      } catch (e) {
        print('Failed to parse userId: $userId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: userId không hợp lệ, vui lòng đăng nhập lại')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      print('Creating Shop - Token: $token');
      print('Creating Shop - UserId: $parsedUserId');
      print('Creating Shop - URL: http://192.168.41.175:9090/api/v1/shops');
      print('Creating Shop - Body: ${jsonEncode({
            'name': _nameController.text,
            'address': _addressController.text,
            'phone': _phoneController.text,
            'description': _descriptionController.text,
            'bankName': _bankNameController.text,
            'accountNumber': _accountNumberController.text,
            'userId': parsedUserId,
            'services': [],
            'imageFiles': [],
          })}');

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/shops');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'description': _descriptionController.text,
          'bankName': _bankNameController.text,
          'accountNumber': _accountNumberController.text,
          'userId': parsedUserId,
          'services': [],
          'imageFiles': [],
        }),
      );

      print('Create Shop - Status Code: ${response.statusCode}');
      print('Create Shop - Response Body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo shop thành công')),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        throw Exception('Dữ liệu không hợp lệ: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode == 401) {
        print('Unauthorized - Token might be invalid or expired');
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền tạo shop: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy người dùng với userId $parsedUserId: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Lỗi khi tạo shop: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Create Shop - Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo shop: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tạo Shop Mới',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF4EA0B7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên Shop *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Địa Chỉ *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Số Điện Thoại * (10-15 chữ số, có thể bắt đầu bằng "+")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô Tả *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bankNameController,
              decoration: InputDecoration(
                labelText: 'Tên Ngân Hàng *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _accountNumberController,
              decoration: InputDecoration(
                labelText: 'Số Tài Khoản * (10-20 chữ số)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator(color: Color(0xFF4EA0B7))
                  : ElevatedButton(
                      onPressed: _createShop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4EA0B7),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Tạo Shop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}