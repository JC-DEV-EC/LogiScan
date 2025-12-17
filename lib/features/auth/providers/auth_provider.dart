import 'package:flutter/foundation.dart';

import '../../../core/services/app_logger.dart';
import '../../../core/services/secure_credentials_service.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecureCredentialsService _secureStorage = SecureCredentialsService();

  bool _isLoading = false;
  String? _error;
  LoginResponse? _loginData;
  bool _isAuthenticated = false;

  AuthProvider(this._authService) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final loginData = await _authService.restoreSession();
      if (loginData != null) {
        _loginData = loginData;
        _isAuthenticated = true;
        notifyListeners();
      } else {
        final saved = await _secureStorage.getCredentials();
        final username = saved['username'];
        final password = saved['password'];
        if (username != null && password != null) {
          await login(username, password);
        }
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
      await logout();
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  LoginResponse? get loginData => _loginData;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    AppLogger.log('Attempting login', source: 'AuthProvider');
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final request = LoginRequest(username: username, password: password);
      final response = await _authService.login(request);

      if (response.isSuccessful && response.content != null) {
        _loginData = response.content;
        _isAuthenticated = true;
        _error = null;

        await _secureStorage.saveCredentials(username, password);
        AppLogger.log('Login successful', source: 'AuthProvider', type: 'SUCCESS');
        return true;
      } else {
        // Mensaje del backend (misma lógica que gbi_logistics)
        _error = response.messageDetail ?? response.message;
        AppLogger.error('Login failed', error: _error ?? 'No message', source: 'AuthProvider');
        return false;
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      AppLogger.error('Login error', error: e, stackTrace: stackTrace, source: 'AuthProvider');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      await _secureStorage.clearCredentials();
      _isAuthenticated = false;
      _loginData = null;
      _error = null;
      notifyListeners();
    }
  }
}
