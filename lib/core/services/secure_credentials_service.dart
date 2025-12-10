import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCredentialsService {
  static const _storage = FlutterSecureStorage();

  static const _keyUsername = 'username';
  static const _keyPassword = 'password';

  Future<void> saveCredentials(String username, String password) async {
    try {
      await _storage.write(key: _keyUsername, value: username);
      await _storage.write(key: _keyPassword, value: password);
    } on MissingPluginException {
      // En plataformas sin plugin simplemente no persistimos credenciales.
    }
  }

  Future<Map<String, String?>> getCredentials() async {
    try {
      final username = await _storage.read(key: _keyUsername);
      final password = await _storage.read(key: _keyPassword);

      return {
        'username': username,
        'password': password,
      };
    } on MissingPluginException {
      return {'username': null, 'password': null};
    }
  }

  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _keyUsername);
      await _storage.delete(key: _keyPassword);
    } on MissingPluginException {
      // No-op.
    }
  }
}
