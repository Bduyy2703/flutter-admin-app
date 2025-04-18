import 'package:flutter/material.dart';
import '../services/apiService.dart';
import '../models/shop.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  _ShopListScreenState createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  final _apiService = ApiService();
  List<Shop> _shops = [];
  bool _isLoading = false;
  int _pageNo = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _loadShops() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final shops = await _apiService.getShops(pageNo: _pageNo);
      setState(() {
        _shops.addAll(shops);
        _pageNo++;
        _hasMore = shops.length == 10; // pageSize = 10
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shops')),
      body: _shops.isEmpty && !_isLoading
          ? const Center(child: Text('No shops available'))
          : ListView.builder(
              itemCount: _shops.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _shops.length) {
                  _loadShops();
                  return const Center(child: CircularProgressIndicator());
                }
                final shop = _shops[index];
                return ListTile(
                  leading: shop.imageUrls != null && shop.imageUrls!.isNotEmpty
                      ? Image.network(shop.imageUrls![0], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.store),
                  title: Text(shop.name),
                  subtitle: Text(shop.address),
                  onTap: () {
                    // Điều hướng đến màn hình chi tiết cửa hàng (tạo sau)
                  },
                );
              },
            ),
    );
  }
}