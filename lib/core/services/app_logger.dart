import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    String type = 'INFO',
  }) {
    final logMessage = '''
----------------------------------------
[$type] ${source != null ? '[$source]' : ''}: $message
${error != null ? '\nError: $error' : ''}
${stackTrace != null ? '\nStack: \n$stackTrace' : ''}
----------------------------------------''';

    debugPrint(logMessage);
  }

  static void apiCall(String endpoint, {String? method, String? body}) {
    log(
      'API Call: ${method ?? 'GET'} $endpoint${body != null ? '\nBody: $body' : ''}',
      source: 'API',
    );
  }

  static void apiResponse(String endpoint, {int? statusCode, String? body}) {
    log(
      'API Response: $endpoint\nStatus: ${statusCode ?? 'Unknown'}\nBody: ${body ?? 'No body'}',
      source: 'API',
    );
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? source}) {
    log(
      message,
      error: error,
      stackTrace: stackTrace,
      source: source,
      type: 'ERROR',
    );
  }
}
