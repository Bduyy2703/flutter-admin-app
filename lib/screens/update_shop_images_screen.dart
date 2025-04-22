import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateShopImagesScreen extends StatefulWidget {
  final int shopId;

  const UpdateShopImagesScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  _UpdateShopImagesScreenState createState() => _UpdateShopImagesScreenState();
}

class _UpdateShopImagesScreenState extends State<UpdateShopImagesScreen> {
  List<File> _images = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _updateImages() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ít nhất một hình ảnh')),
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

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/shops/images/${widget.shopId}');
      final request = http.MultipartRequest('PUT', uri);

      request.headers['Authorization'] = 'Bearer $token';

      for (var image in _images) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật hình ảnh thành công')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật hình ảnh: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cập Nhật Hình Ảnh Shop',
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
            ElevatedButton(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4EA0B7),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Chọn Hình Ảnh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            _images.isEmpty
                ? Center(child: Text('Chưa có hình ảnh nào được chọn'))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _images.map((image) {
                      return Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator(color: Color(0xFF4EA0B7))
                  : ElevatedButton(
                      onPressed: _updateImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4EA0B7),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Cập Nhật Hình Ảnh',
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