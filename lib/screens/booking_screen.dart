import 'package:apehome_admin/controllers/booking_controller.dart';
import 'package:apehome_admin/screens/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building BookingListScreen');
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4EA0B7),
        elevation: 0,
        centerTitle: true,
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
                    const SizedBox(width: 10),
                    _buildStatusFilterChip(controller, 'PENDING', 'Chưa xác nhận'),
                    const SizedBox(width: 10),
                    _buildStatusFilterChip(controller, 'COMPLETED', 'Đã hoàn thành'),
                    const SizedBox(width: 10),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Chưa có đơn hàng nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: controller.fetchBookings,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            itemCount: controller.filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = controller.filteredBookings[index];
                              return FadeInUp(
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                child: Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Hình ảnh cửa hàng
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: booking['shopImage'] ?? 'https://via.placeholder.com/150',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(
                                                  color: Color(0xFF4EA0B7),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(
                                                Icons.store,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        // Thông tin booking
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Tên cửa hàng
                                              Text(
                                                booking['shopName'] ?? 'Không xác định',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2D2D2D),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              // ID đơn hàng
                                              Text(
                                                'Đơn hàng #${booking['id']}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF6B7280),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              // Ngày đặt và Trạng thái
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                    color: Color(0xFF4EA0B7),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      booking['dateBooking']?.split('T')[0] ?? 'Không có ngày',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              // Trạng thái
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(booking['status']),
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      _getStatusText(booking['status']),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              // Tổng tiền
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.monetization_on,
                                                    size: 16,
                                                    color: Color(0xFF4EA0B7),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      '${booking['totalPrice']?.toString() ?? '0'} VND',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF4EA0B7),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Nút hành động
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.visibility,
                                                color: Color(0xFF4EA0B7),
                                                size: 24,
                                              ),
                                              onPressed: () {
                                                print('Navigating to BookingDetailsScreen with bookingId: ${booking['id']}, shopId: ${booking['shopId']}');
                                                Get.to(() => BookingDetailsScreen(
                                                  bookingId: booking['id'],
                                                  shopId: booking['shopId'],
                                                ));
                                              },
                                            ),
                                            if (booking['status'] == 'PENDING')
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.cancel,
                                                  color: Colors.red,
                                                  size: 24,
                                                ),
                                                onPressed: () {
                                                  controller.cancelBooking(booking['id']);
                                                },
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
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
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: TextStyle(
            color: controller.selectedStatus.value == status ? Colors.white : const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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
        side: const BorderSide(color: Color(0xFF4EA0B7), width: 1.5),
      ),
      elevation: 3,
      pressElevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
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
}