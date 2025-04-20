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
    print('Fetching bookings...');
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token: $token');

    if (token == null) {
      print('Error: Token not found, redirecting to login');
      Get.offNamed('/login');
      return;
    }

    // Giải mã token để lấy userId
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['userId']; // tuỳ theo payload của bạn

    print('Decoded userId: $userId');
    if (userId == null) {
      print('Error: userId not found in token, redirecting to login');
      Get.offNamed('/login');
      return;
    }

    final shopsResponse = await apiService.getShopsByUserId(userId.toString(), token);
    print('Shops response: $shopsResponse');

    if (shopsResponse == null || shopsResponse.isEmpty) {
      print('Error: No shops found for user');
      return;
    }

    final shopId = shopsResponse[0]['id'];
    print('Using shopId: $shopId');

    final response = await apiService.getBookingsByShopId(shopId, token);
    print('Bookings response: $response');

    if (response != null) {
      bookings.value = List<Map<String, dynamic>>.from(response);
      filterBookings();
    }
  } catch (e) {
    print('Error fetching bookings: $e');
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