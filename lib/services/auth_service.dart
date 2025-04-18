import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String fullName,
    required bool isPremium,
  }) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'fullName', value: fullName);
    await _storage.write(key: 'isPremium', value: isPremium.toString());
  }

  Future<Map<String, String>?> getAuthData() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final userId = await _storage.read(key: 'userId') ?? '';
    final fullName = await _storage.read(key: 'fullName') ?? '';
    final isPremium = await _storage.read(key: 'isPremium') == 'true';

    return {
      'token': token,
      'userId': userId,
      'fullName': fullName,
      'isPremium': isPremium.toString(),
    };
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}