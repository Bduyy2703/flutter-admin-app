import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apehome_admin/providers/auth_providers.dart';
import 'package:apehome_admin/screens/login_screen.dart';
import 'package:apehome_admin/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apehome Admin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) => auth.isAuthenticated ? HomeScreen() : LoginScreen(),
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}