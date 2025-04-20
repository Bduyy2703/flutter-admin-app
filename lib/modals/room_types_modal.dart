import 'package:apehome_admin/controllers/room_types_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomTypeModal extends StatelessWidget {
  final int? roomTypeId;
  final String? initialName;
  final String? initialNote;

  RoomTypeModal({
    Key? key,
    this.roomTypeId,
    this.initialName,
    this.initialNote,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoomTypesController>();

    // Gán giá trị ban đầu cho các controller
    _nameController.text = initialName ?? '';
    _noteController.text = initialNote ?? '';

    return AlertDialog(
      title: Text(
        roomTypeId == null ? 'Tạo Loại Phòng Mới' : 'Chỉnh Sửa Loại Phòng',
        style: TextStyle(color: Color(0xFF4EA0B7)),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên Loại Phòng *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tên loại phòng không được để trống';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi Chú',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        Obx(() {
          return ElevatedButton(
            onPressed: controller.isModalLoading.value
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final success = await controller.createOrUpdateRoomType(
                      _nameController.text,
                      _noteController.text,
                      roomTypeId,
                    );

                    if (success) {
                      Get.back();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4EA0B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: controller.isModalLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    roomTypeId == null ? 'Tạo' : 'Cập Nhật',
                    style: TextStyle(color: Colors.white),
                  ),
          );
        }),
      ],
    );
  }
}