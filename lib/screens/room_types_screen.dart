import 'package:apehome_admin/controllers/room_types_controller.dart';
import 'package:apehome_admin/modals/room_types_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

// room_types_screen.dart
class RoomTypesScreen extends StatelessWidget {
  const RoomTypesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controller
    Get.put(RoomTypesController());

    return const RoomTypesScreenContent();
  }
}

class RoomTypesScreenContent extends StatelessWidget {
  const RoomTypesScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoomTypesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      appBar: AppBar(
        title: const Text(
          'Danh Sách Loại Phòng',
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
          // Nút "Tạo Loại Phòng Mới"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Get.dialog(RoomTypeModal());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4EA0B7),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Tạo Loại Phòng Mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Danh sách loại phòng
          Expanded(
            child: Obx(() {
              return controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4EA0B7)),
                    )
                  : controller.roomTypes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.room_preferences,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Chưa có loại phòng nào',
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
                          onRefresh: () async {
                            await controller.fetchRoomTypes();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            itemCount: controller.roomTypes.length,
                            itemBuilder: (context, index) {
                              final roomType = controller.roomTypes[index];
                              return FadeInUp(
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                child: Card(
                                  elevation: 6,
                                  margin: const EdgeInsets.only(bottom: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      // Hiển thị chi tiết hoặc chỉnh sửa khi nhấn vào card
                                      Get.dialog(
                                        RoomTypeModal(
                                          roomTypeId: roomType['id'],
                                          initialName: roomType['name'],
                                          initialNote: roomType['note'],
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.grey[100]!,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Hình ảnh minh họa
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF4EA0B7),
                                                    const Color(0xFF3070B3),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.room_preferences,
                                                size: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            // Thông tin loại phòng
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Tên loại phòng
                                                  Text(
                                                    roomType['name'] ?? 'Không tên',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF2D2D2D),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // Ghi chú
                                                  Text(
                                                    'Ghi chú: ${roomType['note'] ?? 'Không có ghi chú'}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
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
                                                    Icons.edit,
                                                    color: Color(0xFF4EA0B7),
                                                    size: 24,
                                                  ),
                                                  onPressed: () {
                                                    Get.dialog(
                                                      RoomTypeModal(
                                                        roomTypeId: roomType['id'],
                                                        initialName: roomType['name'],
                                                        initialNote: roomType['note'],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 24,
                                                  ),
                                                  onPressed: () {
                                                    controller.deleteRoomType(roomType['id']);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
}