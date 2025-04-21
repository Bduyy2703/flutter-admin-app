import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apehome_admin/services/apiService.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class BookingController extends GetxController {
  var bookings = <Map<String, dynamic>>[].obs;
  var filteredBookings = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedStatus = 'ALL'.obs;
  final ApiService apiService = ApiService();

  @override
  void onInit() {
    fetchBookings();
    super.onInit();
  }

  Future<void> fetchBookings() async {
    try {
      print('Đang lấy danh sách booking...');
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Token: $token');

      if (token == null) {
        print('Lỗi: Không tìm thấy token, chuyển hướng đến trang đăng nhập');
        Get.offNamed('/login');
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['userId'];

      print('userId đã giải mã: $userId');
      if (userId == null) {
        print(
          'Lỗi: Không tìm thấy userId trong token, chuyển hướng đến trang đăng nhập',
        );
        Get.offNamed('/login');
        return;
      }

      final shopsResponse = await apiService.getShopsByUserId(
        userId.toString(),
        token,
      );
      print('Danh sách cửa hàng: $shopsResponse');

      if (shopsResponse == null || shopsResponse.isEmpty) {
        print('Lỗi: Không tìm thấy cửa hàng nào của user');
        return;
      }

      bookings.clear();

      for (var shop in shopsResponse) {
        final shopId = shop['id'];
        print('Đang lấy booking cho shopId: $shopId');

        final response = await apiService.getBookingsByShopId(shopId, token);
        print('Danh sách booking cho shop $shopId: $response');

        if (response != null && response.isNotEmpty) {
          var shopBookings =
              List<Map<String, dynamic>>.from(response)
                  .map(
                    (booking) => {
                      ...booking,
                      'shopId': shopId,
                      'shopName': shop['name'],
                      'shopImage':
                          shop['imageFiles'] != null &&
                                  shop['imageFiles'].isNotEmpty
                              ? shop['imageFiles'][0]['url']
                              : null,
                    },
                  )
                  .toList();
          bookings.addAll(shopBookings);
        } else {
          print('Không có booking nào cho shopId: $shopId');
        }
      }

      filterBookings();
    } catch (e) {
      print('Lỗi khi lấy booking: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterBookings() {
    if (selectedStatus.value == 'ALL') {
      filteredBookings.value = bookings;
    } else {
      filteredBookings.value =
          bookings
              .where((booking) => booking['status'] == selectedStatus.value)
              .toList();
    }
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
    filterBookings();
  }

  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      print(
        'Cập nhật trạng thái cho bookingId: $bookingId, trạng thái mới: $newStatus',
      );
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('Error: Token not found, redirecting to login');
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy token, vui lòng đăng nhập lại',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.offNamed('/login');
        return;
      }

      final message = await apiService.updateBookingStatus(
        bookingId,
        newStatus,
        token,
      );
      Get.snackbar(
        'Thành công',
        'Cập nhật trạng thái thành công: $newStatus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Cập nhật trạng thái trong danh sách bookings thay vì xóa
      final index = bookings.indexWhere(
        (booking) => booking['id'] == bookingId,
      );
      if (index != -1) {
        bookings[index]['status'] = newStatus;
        filterBookings();
      } else {
        print('Không tìm thấy booking với id: $bookingId trong danh sách');
      }
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái: $e');
      Get.snackbar(
        'Lỗi',
        'Lỗi khi cập nhật trạng thái: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
