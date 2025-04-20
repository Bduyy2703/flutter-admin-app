import 'package:apehome_admin/screens/room_types_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apehome_admin/screens/login_screen.dart';
import 'package:apehome_admin/screens/home_screen.dart';
import 'package:provider/provider.dart'; // Thêm import cho provider
import 'package:apehome_admin/providers/auth_providers.dart'; // Import AuthProvider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Khởi tạo AuthProvider
      child: GetMaterialApp(
        title: 'Apehome Admin',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'OpenSans',
        ),
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/home', page: () => HomeScreen()),
          GetPage(name: '/room-types', page: () => RoomTypesScreen()),
        ],
      ),
    );
  }
}