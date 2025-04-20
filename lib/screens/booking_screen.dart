import 'package:apehome_admin/controllers/booking_controller.dart';
import 'package:apehome_admin/screens/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building BookingListScreen'); // Logging
    // Khởi tạo controller
    Get.put(BookingController());

    return const BookingListScreenContent();
  }
}

class BookingListScreenContent extends StatelessWidget {
  const BookingListScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      appBar: AppBar(
        title: const Text(
          'Danh Sách Đơn Hàng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4EA0B7),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bộ lọc trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusFilterChip(controller, 'ALL', 'Tất cả'),
                    const SizedBox(width: 8),
                    _buildStatusFilterChip(controller, 'PENDING', 'Chưa xác nhận'),
                    const SizedBox(width: 8),
                    _buildStatusFilterChip(controller, 'COMPLETED', 'Đã hoàn thành'),
                    const SizedBox(width: 8),
                    _buildStatusFilterChip(controller, 'CANCELLED', 'Đã hủy'),
                  ],
                ),
              );
            }),
          ),
          // Danh sách bookings
          Expanded(
            child: Obx(() {
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
                  : controller.filteredBookings.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có đơn hàng nào',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: controller.fetchBookings,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(15),
                            itemCount: controller.filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = controller.filteredBookings[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  title: Text(
                                    'Đơn hàng #${booking['id']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ngày đặt: ${booking['dateBooking'] ?? 'Không có ngày'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      Text(
                                        'Trạng thái: ${_getStatusText(booking['status'])}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _getStatusColor(booking['status']),
                                        ),
                                      ),
                                      Text(
                                        'Tổng tiền: ${booking['totalPrice']?.toString() ?? '0'} VND',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: Color(0xFF4EA0B7)),
                                        onPressed: () {
                                          Get.to(() => BookingDetailsScreen(bookingId: booking['id']));
                                        },
                                      ),
                                      if (booking['status'] == 'PENDING')
                                        IconButton(
                                          icon: const Icon(Icons.cancel, color: Colors.red),
                                          onPressed: () {
                                            controller.cancelBooking(booking['id']);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(BookingController controller, String status, String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: controller.selectedStatus.value == status ? Colors.white : const Color(0xFF2D2D2D),
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: controller.selectedStatus.value == status,
      selectedColor: const Color(0xFF4EA0B7),
      backgroundColor: Colors.white,
      onSelected: (selected) {
        if (selected) {
          controller.changeStatusFilter(status);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF4EA0B7)),
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
        return const Color(0xFFFF9800);
      case 'COMPLETED':
        return const Color(0xFF2196F3);
      case 'CANCELLED':
        return Colors.red;
      default:
        return const Color(0xFF757575);
    }
  }
}