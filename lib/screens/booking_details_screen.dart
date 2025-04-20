import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apehome_admin/services/apiService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

class BookingDetailsScreen extends StatelessWidget {
  final int bookingId;
  final int shopId;

  const BookingDetailsScreen({
    Key? key,
    required this.bookingId,
    required this.shopId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      appBar: AppBar(
        title: Text(
          'Chi Tiết Đơn Hàng #$bookingId',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4EA0B7),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchBookingDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Không thể tải chi tiết đơn hàng: ${snapshot.error ?? 'Không có dữ liệu'}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          final booking = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với hình ảnh cửa hàng
                Stack(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4EA0B7).withOpacity(0.6),
                            const Color(0xFF1976D2).withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: booking['shopImage'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.15),
                        colorBlendMode: BlendMode.darken,
                        memCacheWidth: 300,
                        memCacheHeight: 220,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.store,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['shopName'] ?? 'Cửa hàng không xác định',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking['status']),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _getStatusText(booking['status']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Nội dung chi tiết
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin cửa hàng
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.store,
                                      color: Color(0xFF4EA0B7),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Thông Tin Cửa Hàng',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.location_on,
                                  'Địa chỉ',
                                  booking['shopAddress'] ?? 'Không có thông tin',
                                ),
                                _buildInfoRow(
                                  Icons.phone,
                                  'Số điện thoại',
                                  booking['shopPhone'] ?? 'Không có thông tin',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Thông tin đơn hàng
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      color: Color(0xFF4EA0B7),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Thông Tin Đơn Hàng',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Ngày đặt',
                                  booking['dateBooking']?.split('T')[0] ?? 'Không xác định',
                                ),
                                _buildInfoRow(
                                  Icons.date_range,
                                  'Ngày bắt đầu',
                                  booking['startDate'] ?? 'Không xác định',
                                ),
                                _buildInfoRow(
                                  Icons.date_range,
                                  'Ngày kết thúc',
                                  booking['endDate'] ?? 'Không xác định',
                                ),
                                _buildInfoRow(
                                  Icons.monetization_on,
                                  'Tổng tiền',
                                  '${booking['totalPrice']?.toString() ?? '0'} VND',
                                ),
                                _buildInfoRow(
                                  Icons.pets,
                                  'ID Thú cưng',
                                  booking['petId']?.toString() ?? 'Không xác định',
                                ),
                                _buildInfoRow(
                                  Icons.person,
                                  'ID Khách hàng',
                                  booking['userId']?.toString() ?? 'Không xác định',
                                ),
                                if (booking['note'] != null && booking['note'].isNotEmpty)
                                  _buildInfoRow(
                                    Icons.note,
                                    'Ghi chú',
                                    booking['note'],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Dịch vụ đã chọn
                      if (booking['careServices'] != null && (booking['careServices'] as List).isNotEmpty) ...[
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.room_service,
                                color: Color(0xFF4EA0B7),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Dịch Vụ Đã Chọn',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(booking['careServices'].length, (index) {
                          final service = booking['careServices'][index];
                          return FadeInUp(
                            duration: Duration(milliseconds: 700 + (index * 100)),
                            child: Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Icon(
                                  _getServiceIcon(service['type']),
                                  color: const Color(0xFF4EA0B7),
                                ),
                                title: Text(
                                  service['name'] ?? 'Không tên',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                subtitle: Text(
                                  'Giá: ${service['price']?.toString() ?? '0'} VND',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                trailing: service['description'] != null && service['description'].isNotEmpty
                                    ? Text(
                                        service['description'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.snackbar('Lỗi', 'Không tìm thấy token, vui lòng đăng nhập lại',
            backgroundColor: Colors.red, colorText: Colors.white);
        Get.offNamed('/login');
        return null;
      }

      final apiService = ApiService();
      final bookingDetails = await apiService.getBookingDetails(bookingId, token);

      if (bookingDetails != null) {
        // Lấy thông tin cửa hàng trực tiếp bằng shopId
        final shop = await apiService.getShopById(shopId, token);
        print('Shop data for shopId $shopId: $shop'); // Debug log
        if (shop != null) {
          bookingDetails['shopName'] = shop['name'];
          bookingDetails['shopAddress'] = shop['address'];
          bookingDetails['shopPhone'] = shop['phone'];
          bookingDetails['shopImage'] = shop['imageFiles'] != null && shop['imageFiles'].isNotEmpty
              ? shop['imageFiles'][0]['url']
              : null;
        } else {
          print('Không tìm thấy cửa hàng với shopId: $shopId');
          Get.snackbar(
            'Lỗi',
            'Không tìm thấy thông tin cửa hàng cho đơn hàng này',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }

      return bookingDetails;
    } catch (e) {
      print('Lỗi khi lấy chi tiết đơn hàng: $e');
      Get.snackbar('Lỗi', 'Lỗi khi lấy chi tiết đơn hàng: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'PENDING':
        return 'Chưa xác nhận';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFA726);
      case 'COMPLETED':
        return const Color(0xFF1976D2);
      case 'CANCELLED':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getServiceIcon(String? type) {
    switch (type) {
      case 'spa':
        return Icons.bathroom;
      case 'vet':
        return Icons.medical_services;
      case 'vaccine':
        return Icons.vaccines;
      case 'hotel':
        return Icons.hotel;
      default:
        return Icons.pets;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4EA0B7), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D2D2D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}