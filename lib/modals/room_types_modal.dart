import 'package:apehome_admin/providers/room_types_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomTypeModal extends StatefulWidget {
  final int? roomTypeId;
  final String? initialName;
  final String? initialNote;

  const RoomTypeModal({
    Key? key,
    this.roomTypeId,
    this.initialName,
    this.initialNote,
  }) : super(key: key);

  @override
  _RoomTypeModalState createState() => _RoomTypeModalState();
}

class _RoomTypeModalState extends State<RoomTypeModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.roomTypeId == null ? 'Tạo Loại Phòng Mới' : 'Chỉnh Sửa Loại Phòng',
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
            Navigator.pop(context);
          },
          child: Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        Consumer<RoomTypesProvider>(
          builder: (context, provider, child) {
            return ElevatedButton(
              onPressed: provider.isModalLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final success = await provider.createOrUpdateRoomType(
                        context,
                        _nameController.text,
                        _noteController.text,
                        widget.roomTypeId,
                      );

                      if (success) {
                        Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4EA0B7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: provider.isModalLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.roomTypeId == null ? 'Tạo' : 'Cập Nhật',
                      style: TextStyle(color: Colors.white),
                    ),
            );
          },
        ),
      ],
    );
  }
}