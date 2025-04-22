import 'package:apehome_admin/screens/rooms_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apehome_admin/screens/care_services_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:animate_do/animate_do.dart';

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
  bool _isUpdating = false; // Trạng thái loading cho nút

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>(); // Dùng để kiểm tra form

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
    _phoneController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchShopDetails() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://172.20.10.3:9090/api/v1/shops/${widget.shopId}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Lấy chi tiết shop - Dữ liệu thô: ${response.body}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _shopDetails = data;
          _nameController.text = _shopDetails!['name'] ?? '';
          _addressController.text = _shopDetails!['address'] ?? '';
          _descriptionController.text = _shopDetails!['description'] ?? '';
          _phoneController.text = _shopDetails!['phone'] ?? '';
          _bankNameController.text = _shopDetails!['bankName'] ?? '';
          _accountNumberController.text = _shopDetails!['accountNumber'] ?? '';
        });
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi tải chi tiết shop: ${response.statusCode}');
      }
    } catch (e) {
      print('Lấy chi tiết shop - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải chi tiết shop. Vui lòng thử lại!')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateShopDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isUpdating = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://172.20.10.3:9090/api/v1/shops/${widget.shopId}');
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
          'phone': _phoneController.text,
          'bankName': _bankNameController.text,
          'accountNumber': _accountNumberController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thông tin shop thành công')),
        );
        await _fetchShopDetails();
        setState(() {
          _isEditing = false;
        });
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi cập nhật shop: ${response.statusCode}');
      }
    } catch (e) {
      print('Cập nhật chi tiết shop - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật thông tin shop. Vui lòng thử lại!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isUpdating = false;
      });
    }
  }

  Future<void> _updateShopImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn hình ảnh trước khi cập nhật')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isUpdating = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token bị null, chuyển hướng đến đăng nhập');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uri = Uri.parse('http://172.20.10.3:9090/api/v1/shops/images/${widget.shopId}');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('images', _selectedImage!.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật hình ảnh shop thành công')),
        );
        await _fetchShopDetails();
        setState(() {
          _selectedImage = null;
          _isEditing = false;
        });
      } else if (response.statusCode == 401) {
        print('Không có quyền - Token có thể không hợp lệ hoặc hết hạn');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Lỗi khi cập nhật hình ảnh: ${response.statusCode}');
      }
    } catch (e) {
      print('Cập nhật hình ảnh shop - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật hình ảnh. Vui lòng thử lại!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isUpdating = false;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
    PermissionStatus status;
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }
    } catch (e) {
      print('Lỗi khi kiểm tra thông tin thiết bị: $e');
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    } else {
      return false;
    }
  }

  Future<void> _pickImage() async {
    print('Đang cố gắng chọn hình ảnh...');

    bool permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      print('Không có quyền truy cập thư viện ảnh');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có quyền truy cập thư viện hình ảnh')),
      );
      return;
    }

    try {
      print('Mở công cụ chọn ảnh...');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        print('Hình ảnh đã chọn: ${pickedFile.path}');
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print('Không có hình ảnh nào được chọn');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không có hình ảnh nào được chọn')),
        );
      }
    } catch (e) {
      print('Chọn hình ảnh - Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn hình ảnh. Vui lòng thử lại!')),
      );
    }
  }

  void _navigateToCareServices() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CareServicesScreen(shopId: widget.shopId)),
    );
  }

  void _navigateToRooms() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomsScreen(shopId: widget.shopId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopImage = _shopDetails != null && _shopDetails!['imageFiles'] != null && _shopDetails!['imageFiles'].isNotEmpty
        ? _shopDetails!['imageFiles'][0]['url']
        : 'https://i.imgur.com/1tMFzp8.png';

    return Scaffold(
      backgroundColor: Color(0xFFF5F6F5),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
          : _shopDetails == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                      SizedBox(height: 12),
                      Text(
                        'Không tìm thấy shop',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250.0,
                      floating: false,
                      pinned: true,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          _isEditing ? 'Chỉnh Sửa Shop' : _shopDetails!['name'] ?? 'Không tên',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 1.2,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            _isEditing && _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : Image.network(
                                    shopImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.store, size: 100, color: Colors.grey[600]),
                                    ),
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.7),
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
                            semanticLabel: _isEditing ? 'Hủy chỉnh sửa' : 'Chỉnh sửa',
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isEditing) {
                                _isEditing = false;
                                _selectedImage = null;
                                _nameController.text = _shopDetails!['name'] ?? '';
                                _addressController.text = _shopDetails!['address'] ?? '';
                                _descriptionController.text = _shopDetails!['description'] ?? '';
                                _phoneController.text = _shopDetails!['phone'] ?? '';
                                _bankNameController.text = _shopDetails!['bankName'] ?? '';
                                _accountNumberController.text = _shopDetails!['accountNumber'] ?? '';
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
                            FadeInUp(
                              duration: Duration(milliseconds: 500),
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [Colors.white, Colors.grey[50]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Thông Tin Shop',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D2D2D),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          if (_isEditing) ...[
                                            TextFormField(
                                              controller: _nameController,
                                              decoration: InputDecoration(
                                                labelText: 'Tên Shop',
                                                prefixIcon: Icon(Icons.store, color: Color(0xFF4EA0B7)),
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
                                                  return 'Vui lòng nhập tên shop';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 12),
                                            TextFormField(
                                              controller: _addressController,
                                              decoration: InputDecoration(
                                                labelText: 'Địa Chỉ',
                                                prefixIcon: Icon(Icons.location_on, color: Color(0xFF4EA0B7)),
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
                                                  return 'Vui lòng nhập địa chỉ';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 12),
                                            TextFormField(
                                              controller: _phoneController,
                                              decoration: InputDecoration(
                                                labelText: 'Số Điện Thoại',
                                                prefixIcon: Icon(Icons.phone, color: Color(0xFF4EA0B7)),
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
                                              keyboardType: TextInputType.phone,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Vui lòng nhập số điện thoại';
                                                }
                                                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                                  return 'Số điện thoại không hợp lệ (10 chữ số)';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 12),
                                            TextFormField(
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
                                            ),
                                            SizedBox(height: 12),
                                            TextFormField(
                                              controller: _bankNameController,
                                              decoration: InputDecoration(
                                                labelText: 'Tên Ngân Hàng',
                                                prefixIcon: Icon(Icons.account_balance, color: Color(0xFF4EA0B7)),
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
                                            ),
                                            SizedBox(height: 12),
                                            TextFormField(
                                              controller: _accountNumberController,
                                              decoration: InputDecoration(
                                                labelText: 'Số Tài Khoản',
                                                prefixIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF4EA0B7)),
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
                                                if (value != null && value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                                                  return 'Số tài khoản không hợp lệ';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 16),
                                            FadeInUp(
                                              duration: Duration(milliseconds: 600),
                                              child: ElevatedButton(
                                                onPressed: _isUpdating ? null : _pickImage,
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.image, color: Colors.white),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Chọn Hình Ảnh',
                                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_selectedImage != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: Text(
                                                  'Hình ảnh đã chọn: ${_selectedImage!.path.split('/').last}',
                                                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                                                ),
                                              ),
                                            SizedBox(height: 20),
                                            FadeInUp(
                                              duration: Duration(milliseconds: 700),
                                              child: Center(
                                                child: ElevatedButton(
                                                  onPressed: _isUpdating
                                                      ? null
                                                      : () async {
                                                          await _updateShopDetails();
                                                          if (_selectedImage != null) {
                                                            await _updateShopImage();
                                                          }
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                                                      child: _isUpdating
                                                          ? SizedBox(
                                                              width: 20,
                                                              height: 20,
                                                              child: CircularProgressIndicator(
                                                                color: Colors.white,
                                                                strokeWidth: 2,
                                                              ),
                                                            )
                                                          : Text(
                                                              'Lưu Thay Đổi',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                                letterSpacing: 0.5,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ] else ...[
                                            _buildInfoRow(
                                              icon: Icons.store,
                                              label: 'Tên',
                                              value: _shopDetails!['name'] ?? 'Không có tên',
                                            ),
                                            SizedBox(height: 12),
                                            _buildInfoRow(
                                              icon: Icons.location_on,
                                              label: 'Địa chỉ',
                                              value: _shopDetails!['address'] ?? 'Không có địa chỉ',
                                            ),
                                            SizedBox(height: 12),
                                            _buildInfoRow(
                                              icon: Icons.phone,
                                              label: 'Số điện thoại',
                                              value: _shopDetails!['phone'] ?? 'Không có số điện thoại',
                                            ),
                                            SizedBox(height: 12),
                                            _buildInfoRow(
                                              icon: Icons.description,
                                              label: 'Mô tả',
                                              value: _shopDetails!['description'] ?? 'Không có mô tả',
                                              maxLines: 3,
                                            ),
                                            SizedBox(height: 12),
                                            _buildInfoRow(
                                              icon: Icons.account_balance,
                                              label: 'Ngân hàng',
                                              value: _shopDetails!['bankName'] ?? 'Không có tên ngân hàng',
                                            ),
                                            SizedBox(height: 12),
                                            _buildInfoRow(
                                              icon: Icons.account_balance_wallet,
                                              label: 'Số tài khoản',
                                              value: _shopDetails!['accountNumber'] ?? 'Không có số tài khoản',
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            FadeInUp(
                              duration: Duration(milliseconds: 600),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: _buildNavigationButton(
                                      label: 'Quản Lý Dịch Vụ',
                                      icon: Icons.pets,
                                      onPressed: _navigateToCareServices,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildNavigationButton(
                                      label: 'Quản Lý Phòng',
                                      icon: Icons.room_preferences,
                                      onPressed: _navigateToRooms,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value, int maxLines = 1}) {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF4EA0B7), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Color(0xFF2D2D2D)),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return FadeInUp(
      duration: Duration(milliseconds: 600),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}