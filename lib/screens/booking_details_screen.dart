import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apehome_admin/services/apiService.dart';

class BookingDetailsScreen extends StatelessWidget {
  final int bookingId;

  const BookingDetailsScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      appBar: AppBar(
        title: Text(
          'Chi Tiết Đơn Hàng #$bookingId',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4EA0B7),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchBookingDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)));
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
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trạng thái
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking['status']),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      _getStatusText(booking['status']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Thông tin đơn hàng
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.calendar_today, 'Ngày đặt', booking['dateBooking'] ?? 'Không xác định'),
                        _buildInfoRow(Icons.date_range, 'Ngày bắt đầu', booking['startDate'] ?? 'Không xác định'),
                        _buildInfoRow(Icons.date_range, 'Ngày kết thúc', booking['endDate'] ?? 'Không xác định'),
                        _buildInfoRow(Icons.monetization_on, 'Tổng tiền', '${booking['totalPrice']?.toString() ?? '0'} VND'),
                        if (booking['note'] != null && booking['note'].isNotEmpty)
                          _buildInfoRow(Icons.note, 'Ghi chú', booking['note']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Dịch vụ đã chọn
                if (booking['careServices'] != null && (booking['careServices'] as List).isNotEmpty) ...[
                  const Text(
                    'Dịch vụ đã chọn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(booking['careServices'].length, (index) {
                    final service = booking['careServices'][index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    );
                  }),
                ],
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
      return await apiService.getBookingDetails(bookingId, token);
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi lấy chi tiết đơn hàng: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
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
        return const Color(0xFFFF9800);
      case 'COMPLETED':
        return const Color(0xFF2196F3);
      case 'CANCELLED':
        return Colors.red;
      default:
        return const Color(0xFF757575);
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
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D2D2D),
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