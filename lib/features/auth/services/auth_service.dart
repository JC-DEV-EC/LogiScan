import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/http_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/secure_credentials_service.dart';
import '../models/auth_models.dart';

/// Servicio para autenticación en LogiScan
class AuthService {
  final HttpService _http;
  final StorageService _storage;
  final SecureCredentialsService _secureStorage;

  AuthService(this._http, this._storage, this._secureStorage) {
    _restoreToken();
  }

  Future<LoginResponse?> restoreSession() async {
    final hasSession = await _storage.hasActiveSession();
    final token = await _storage.getToken();
    final loginData = await _storage.getLoginData();

    if (hasSession && token != null) {
      _http.setToken(token);
      if (loginData != null) {
        return LoginResponse.fromJson(loginData);
      }
    }
    return null;
  }

  Future<void> _restoreToken() async {
    final token = await _storage.getToken();
    if (token != null) {
      _http.setToken(token);
    }
  }

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _http.post<LoginResponse>(
        ApiEndpoints.login,
        request.toJson(),
        (json) => LoginResponse.fromJson(json),
      );

      if (response.isSuccessful && response.content?.token != null) {
        final token = response.content!.token!;
        final loginData = response.content!;
        _http.setToken(token);
        await _storage.setToken(token);
        await _storage.setLoginData(loginData.toJson());
      } else if (!response.isSuccessful) {
        return ApiResponse.error(
          messageDetail: response.messageDetail,
          content: LoginResponse.empty(),
        );
      }

      return response;
    } catch (_) {
      return ApiResponse.error(
        messageDetail: null,
        content: LoginResponse.empty(),
      );
    }
  }

  Future<void> logout() async {
    _http.setToken(null);
    await _storage.clearSession();
    await _secureStorage.clearCredentials();
  }

  Future<bool> hasValidToken() async {
    final token = await _storage.getToken();
    if (token == null) return false;

    // Aquí podríamos llamar a un endpoint de health o perfil.
    // De momento, solo verificamos que haya token almacenado.
    return true;
  }

  bool _isRefreshing = false;

  Future<bool> refreshTokenIfNeeded() async {
    if (_isRefreshing) return true;

    try {
      _isRefreshing = true;
      final hasSession = await _storage.hasActiveSession();
      if (!hasSession) return false;

      final tokenData = await _storage.getTokenData();
      if (tokenData == null) return false;

      final expiresAt = tokenData.expiresAt;
      final now = DateTime.now();

      if (expiresAt.difference(now) > ApiConfig.refreshTokenBeforeExpiry) {
        return true;
      }

      final saved = await _secureStorage.getCredentials();
      final username = saved['username'];
      final password = saved['password'];

      if (username != null && password != null) {
        final loginRequest = LoginRequest(username: username, password: password);
        final loginResponse = await login(loginRequest);
        return loginResponse.isSuccessful;
      }

      // Si no hay credenciales guardadas, intentar refresh-token clásico
      final response = await _http.post<LoginResponse>(
        ApiEndpoints.refreshToken,
        {
          'token': tokenData.token,
        },
        (json) => LoginResponse.fromJson(json),
        suppressAuthHandling: true,
      );

      if (response.isSuccessful && response.content?.token != null) {
        final newToken = response.content!.token!;
        _http.setToken(newToken);
        await _storage.setToken(newToken);
        if (response.content != null) {
          await _storage.setLoginData(response.content!.toJson());
        }
        return true;
      }

      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
