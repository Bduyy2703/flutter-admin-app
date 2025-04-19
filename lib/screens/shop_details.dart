import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apehome_admin/screens/care_services_screen.dart';
import 'package:apehome_admin/screens/room_types_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ShopDetailsScreen extends StatefulWidget {
  final int shopId;

  const ShopDetailsScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  _ShopDetailsScreenState createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  Map<String, dynamic>? _shopDetails;
  bool _isLoading = true;
  bool _isEditing = false;

  // Các controller để chỉnh sửa thông tin
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchShopDetails() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/shops/${widget.shopId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Fetch Shop Details - Raw response body: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _shopDetails = data;
          _nameController.text = _shopDetails!['name'] ?? '';
          _addressController.text = _shopDetails!['address'] ?? '';
          _descriptionController.text = _shopDetails!['description'] ?? '';
        });
      } else {
        print('Fetch Shop Details - Error: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi khi tải chi tiết shop: ${response.statusCode} - ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Fetch Shop Details - Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateShopDetails() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      print('Updating Shop Details - Token: $token');
      print('Updating Shop Details - Body: ${jsonEncode({
            'name': _nameController.text,
            'address': _addressController.text,
            'description': _descriptionController.text,
          })}');

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/shops/${widget.shopId}');
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'address': _addressController.text,
          'description': _descriptionController.text,
        }),
      );

      print('Update Shop Details - Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thông tin shop thành công')),
        );
        await _fetchShopDetails(); // Làm mới dữ liệu
        setState(() {
          _isEditing = false;
        });
      } else {
        throw Exception('Lỗi khi cập nhật shop: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Update Shop Details - Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateShopImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn hình ảnh trước khi cập nhật')),
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

      print('Updating Shop Image - Token: $token');
      print('Updating Shop Image - Image Path: ${_selectedImage!.path}');

      final uri = Uri.parse('http://192.168.1.29:9090/api/v1/shops/images/${widget.shopId}');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('images', _selectedImage!.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Update Shop Image - Response: ${response.statusCode} - $responseBody');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật hình ảnh shop thành công')),
        );
        await _fetchShopDetails(); // Làm mới dữ liệu
        setState(() {
          _selectedImage = null;
          _isEditing = false;
        });
      } else {
        throw Exception('Lỗi khi cập nhật hình ảnh: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('Update Shop Image - Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _requestStoragePermission() async {
    // Kiểm tra quyền cho Android 13+ (READ_MEDIA_IMAGES) và Android 12 trở về trước (READ_EXTERNAL_STORAGE)
    PermissionStatus status;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.photos.request(); // READ_MEDIA_IMAGES
      } else {
        status = await Permission.storage.request(); // READ_EXTERNAL_STORAGE
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    } else {
      return false;
    }
  }

  Future<void> _pickImage() async {
    // Yêu cầu quyền trước khi mở thư viện hình ảnh
    bool permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có quyền truy cập thư viện hình ảnh')),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Pick Image - Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn hình ảnh: $e')),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _navigateToCareServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CareServicesScreen(shopId: widget.shopId),
      ),
    );
  }

  void _navigateToRoomTypes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomTypesScreen(shopId: widget.shopId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopImage = _shopDetails != null &&
            _shopDetails!['imageFiles'] != null &&
            _shopDetails!['imageFiles'].isNotEmpty
        ? _shopDetails!['imageFiles'][0]['url']
        : 'https://i.imgur.com/1tMFzp8.png';

    final services = _shopDetails != null && _shopDetails!['services'] != null
        ? _shopDetails!['services'] as List
        : [];

    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
          : _shopDetails == null
              ? Center(
                  child: Text(
                    'Không tìm thấy shop',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: Color(0xFF4EA0B7),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          _isEditing
                              ? 'Chỉnh Sửa Shop'
                              : _shopDetails!['name'] ?? 'Không tên',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            _isEditing && _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    shopImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.store,
                                        size: 100,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            _isEditing ? Icons.close : Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isEditing) {
                                _isEditing = false;
                                _selectedImage = null;
                                _nameController.text = _shopDetails!['name'] ?? '';
                                _addressController.text = _shopDetails!['address'] ?? '';
                                _descriptionController.text =
                                    _shopDetails!['description'] ?? '';
                              } else {
                                _isEditing = true;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thông tin shop
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thông Tin Shop',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    if (_isEditing) ...[
                                      TextField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Tên Shop',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: _addressController,
                                        decoration: InputDecoration(
                                          labelText: 'Địa Chỉ',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
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
                                      SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: _pickImage,
                                        icon: Icon(Icons.image, color: Colors.white),
                                        label: Text(
                                          'Chọn Hình Ảnh',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF4EA0B7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      if (_selectedImage != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            'Hình ảnh đã chọn: ${_selectedImage!.path.split('/').last}',
                                            style: TextStyle(color: Color(0xFF6B7280)),
                                          ),
                                        ),
                                      SizedBox(height: 20),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await _updateShopDetails();
                                            if (_selectedImage != null) {
                                              await _updateShopImage();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF4EA0B7),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 50, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                          child: Text(
                                            'Lưu Thay Đổi',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Color(0xFF4EA0B7), size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Địa chỉ: ${_shopDetails!['address'] ?? 'Không có địa chỉ'}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.description,
                                              color: Color(0xFF4EA0B7), size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Mô tả: ${_shopDetails!['description'] ?? 'Không có mô tả'}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Nút điều hướng đến danh sách dịch vụ và loại phòng
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _navigateToCareServices,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4EA0B7),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Quản Lý Dịch Vụ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _navigateToRoomTypes,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4EA0B7),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Quản Lý Loại Phòng',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Danh sách dịch vụ
                            Text(
                              'Dịch Vụ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            SizedBox(height: 10),
                            services.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Không có dịch vụ nào',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: services.length,
                                    itemBuilder: (context, index) {
                                      final service = services[index];
                                      return Card(
                                        elevation: 2,
                                        margin: EdgeInsets.only(bottom: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          leading: Icon(
                                            Icons.pets,
                                            color: Color(0xFF4EA0B7),
                                            size: 30,
                                          ),
                                          title: Text(
                                            service['type'] ?? 'Không tên',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D2D2D),
                                            ),
                                          ),
                                          subtitle: Text(
                                            service['description'] ?? 'Không có mô tả',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          trailing: Text(
                                            '${_formatPrice((service['price'] as num).toInt())} VND',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4EA0B7),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}