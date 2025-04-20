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
      print('Lỗi: Không tìm thấy userId trong token, chuyển hướng đến trang đăng nhập');
      Get.offNamed('/login');
      return;
    }

    final shopsResponse = await apiService.getShopsByUserId(userId.toString(), token);
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
        var shopBookings = List<Map<String, dynamic>>.from(response)
            .map((booking) => {
                  ...booking,
                  'shopId': shopId,
                  'shopName': shop['name'],
                  'shopImage': shop['imageFiles'] != null && shop['imageFiles'].isNotEmpty
                      ? shop['imageFiles'][0]['url']
                      : null,
                })
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
      filteredBookings.value = bookings.where((booking) => booking['status'] == selectedStatus.value).toList();
    }
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
    filterBookings();
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('Error: Token not found, redirecting to login'); // Logging
        Get.offNamed('/login');
        return;
      }

      final success = await apiService.cancelBooking(bookingId, token);
      if (success != null) {
        bookings.removeWhere((booking) => booking['id'] == bookingId);
        filterBookings();
        Get.snackbar('Thành công', 'Đã hủy đơn hàng',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Lỗi', 'Không thể hủy đơn hàng',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi hủy đơn hàng: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}