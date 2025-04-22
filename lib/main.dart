import 'package:apehome_admin/screens/booking_screen.dart';
import 'package:apehome_admin/screens/pet_types_screen.dart';
import 'package:apehome_admin/screens/room_types_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apehome_admin/screens/login_screen.dart';
import 'package:apehome_admin/screens/home_screen.dart';
import 'package:apehome_admin/screens/shop_list_screen.dart';
import 'package:apehome_admin/screens/setting_screen.dart';
import 'package:provider/provider.dart';
import 'package:apehome_admin/providers/auth_providers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: GetMaterialApp(
        title: 'Apehome Admin',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'OpenSans'),
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/home', page: () => HomeScreen()),
          GetPage(name: '/room-types', page: () => RoomTypesScreen()),
          GetPage(name: '/pet-types', page: () => PetTypesScreen()),
          GetPage(name: '/bookings', page: () => BookingListScreen()),
          GetPage(name: '/shops', page: () => ShopListScreen()),
          GetPage(name: '/settings', page: () => SettingsScreen()),
        ],
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => LoginScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => HomeScreen());
            case '/room-types':
              return MaterialPageRoute(builder: (_) => RoomTypesScreen());
            case '/bookings':
              return MaterialPageRoute(builder: (_) => BookingListScreen());
            case '/shops':
              return MaterialPageRoute(builder: (_) => ShopListScreen());
            case '/settings':
              return MaterialPageRoute(builder: (_) => SettingsScreen());
            case '/pet-types':
              return MaterialPageRoute(builder: (_) => PetTypesScreen());
            default:
              return MaterialPageRoute(builder: (_) => LoginScreen());
          }
        },
      ),
    );
  }
}
