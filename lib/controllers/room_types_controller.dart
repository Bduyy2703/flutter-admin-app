
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomTypesController extends GetxController {
  var roomTypes = <dynamic>[].obs; // Danh sách loại phòng
  var isLoading = false.obs; // Trạng thái loading cho danh sách
  var isModalLoading = false.obs; // Trạng thái loading cho modal

  @override
  void onInit() {
    super.onInit();
    fetchRoomTypes();
  }

  Future<void> fetchRoomTypes() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/room-types');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        roomTypes.assignAll(data);
      } else {
        Get.snackbar('Lỗi', 'Lỗi khi tải danh sách loại phòng: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRoomType(int roomTypeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final uri = Uri.parse('http://192.168.41.175:9090/api/v1/room-types/$roomTypeId');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        roomTypes.removeWhere((roomType) => roomType['id'] == roomTypeId);
        Get.snackbar('Thành công', 'Xóa loại phòng thành công');
      } else {
        Get.snackbar('Lỗi', 'Lỗi khi xóa loại phòng: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi: $e');
    }
  }

  Future<bool> createOrUpdateRoomType(String name, String note, int? roomTypeId) async {
    isModalLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        isModalLoading.value = false;
        return false;
      }

      final uri = Uri.parse(
        roomTypeId == null
            ? 'http://192.168.41.175:9090/api/v1/room-types'
            : 'http://192.168.41.175:9090/api/v1/room-types/$roomTypeId',
      );

      final response = roomTypeId == null
          ? await http.post(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                'name': name,
                'note': note,
              }),
            )
          : await http.put(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                'name': name,
                'note': note,
              }),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchRoomTypes();
        Get.snackbar(
          'Thành công',
          roomTypeId == null ? 'Tạo loại phòng thành công' : 'Cập nhật loại phòng thành công',
        );
        return true;
      } else {
        Get.snackbar('Lỗi', 'Lỗi: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi: $e');
      return false;
    } finally {
      isModalLoading.value = false;
    }
  }
}