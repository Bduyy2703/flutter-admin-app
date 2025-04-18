import 'package:flutter/material.dart';

class BookingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Đơn hàng'),
        backgroundColor: Color(0xFF4EA0B7),
      ),
      body: Center(child: Text('Hiển thị danh sách đơn hàng')),
    );
  }
}