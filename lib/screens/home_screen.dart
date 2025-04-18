import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ApeHome Admin')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed('/shops'),
              child: const Text('Manage Shops'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Thêm các tính năng quản lý khác (users, services, v.v.)
              },
              child: const Text('Manage Services'),
            ),
          ],
        ),
      ),
    );
  }
}