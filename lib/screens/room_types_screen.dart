import 'package:apehome_admin/modals/room_types_modal.dart';
import 'package:apehome_admin/providers/room_types_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// room_types_screen.dart
class RoomTypesScreen extends StatelessWidget {
  const RoomTypesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomTypesProvider(),
      child: const RoomTypesScreenContent(),
    );
  }
}

class RoomTypesScreenContent extends StatefulWidget {
  const RoomTypesScreenContent({Key? key}) : super(key: key);

  @override
  _RoomTypesScreenContentState createState() => _RoomTypesScreenContentState();
}

class _RoomTypesScreenContentState extends State<RoomTypesScreenContent> {
  @override
  void initState() {
    super.initState();
    // Gọi fetchRoomTypes khi màn hình khởi tạo
    Provider.of<RoomTypesProvider>(context, listen: false).fetchRoomTypes(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomTypesProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Color(0xFFF5F6F5),
          appBar: AppBar(
            title: Text(
              'Danh Sách Loại Phòng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFF4EA0B7),
            elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => RoomTypeModal(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4EA0B7),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
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
              Expanded(
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator(color: Color(0xFF4EA0B7)))
                    : provider.roomTypes.isEmpty
                        ? Center(
                            child: Text(
                              'Chưa có loại phòng nào',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(15),
                            itemCount: provider.roomTypes.length,
                            itemBuilder: (context, index) {
                              final roomType = provider.roomTypes[index];
                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  title: Text(
                                    roomType['name'] ?? 'Không tên',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Ghi chú: ${roomType['note'] ?? 'Không có ghi chú'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Color(0xFF4EA0B7)),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => RoomTypeModal(
                                              roomTypeId: roomType['id'],
                                              initialName: roomType['name'],
                                              initialNote: roomType['note'],
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          provider.deleteRoomType(context, roomType['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}