/// Configuración de la API para LogiScan
class ApiConfig {
  /// Tiempo antes de expiración para refrescar el token (30 minutos)
  static const refreshTokenBeforeExpiry = Duration(minutes: 30);

  /// Intervalo para verificar el estado del token (15 minutos)
  static const tokenCheckInterval = Duration(minutes: 15);

  /// URL base de la API de desarrollo
  static const String devBaseUrl = 'http://100.104.120.121:81';

  /// URL base de la API de producción
  static const String prodBaseUrl = 'https://internalapi.gbilogistics.net';

  /// Modo de desarrollo (cambiar a false para producción)
  static const bool isDevelopment = false;

  /// URL base de la API (selecciona según el modo)
  static String get baseUrl => isDevelopment ? devBaseUrl : prodBaseUrl;

  /// Versión de la API
  static const String version = '1.0';

  /// Base path para todos los endpoints de la API
  static String get apiPath => '/api/v$version';

  /// Construye una URL completa para un endpoint
  static String buildUrl(String endpoint) {
    return '$apiPath$endpoint';
  }
}

/// Endpoints de la API usados por LogiScan
class ApiEndpoints {
  static String get auth => ApiConfig.buildUrl('/Auth');
  static String get login => ApiConfig.buildUrl('/Auth/login');
  static String get refreshToken => ApiConfig.buildUrl('/Auth/refresh-token');
}
