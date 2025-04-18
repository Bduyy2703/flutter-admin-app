import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
        backgroundColor: Color(0xFF4EA0B7),
      ),
      body: Center(child: Text('Trang cài đặt')),
    );
  }
}