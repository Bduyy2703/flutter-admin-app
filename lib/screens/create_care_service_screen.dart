import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCareServiceScreen extends StatefulWidget {
  final int shopId;

  const CreateCareServiceScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  _CreateCareServiceScreenState createState() => _CreateCareServiceScreenState();
}

class _CreateCareServiceScreenState extends State<CreateCareServiceScreen> {
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createService() async {
    if (_typeController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập loại dịch vụ và giá')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/services');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'type': _typeController.text,
          'description': _descriptionController.text,
          'price': int.parse(_priceController.text),
          'shopId': widget.shopId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo dịch vụ thành công')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Lỗi khi tạo dịch vụ: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo dịch vụ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tạo Dịch Vụ Mới',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF4EA0B7),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Loại Dịch Vụ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô Tả',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Giá (VND)',
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
                      onPressed: _createService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4EA0B7),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Tạo Dịch Vụ',
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