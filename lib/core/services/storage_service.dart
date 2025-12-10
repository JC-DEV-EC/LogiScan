import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para almacenamiento persistente básico (token y sesión)
class StorageService {
  final _prefs = SharedPreferences.getInstance();

  static const _tokenKey = 'auth_token';
  static const _tokenExpiryKey = 'auth_token_expiry';
  static const _loginDataKey = 'auth_login_data';
  static const _sessionKey = 'session_active';

  Future<String?> getToken() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_tokenKey);
    } on MissingPluginException {
      // En entornos donde shared_preferences no esté disponible (p.ej. hot restart
      // sin reinicio completo), devolvemos null de forma segura.
      return null;
    }
  }

  Future<void> setToken(String token) async {
    final expiresAt = DateTime.now().add(const Duration(hours: 1));
    await setTokenWithExpiry(token, expiresAt);
  }

  Future<void> setTokenWithExpiry(String token, DateTime expiresAt) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String());
    } on MissingPluginException {
      // Ignorar en entornos sin soporte de plugin.
    }
  }

  Future<void> removeToken() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenExpiryKey);
    } on MissingPluginException {
      // No-op si no hay plugin.
    }
  }

  Future<TokenData?> getTokenData() async {
    try {
      final prefs = await _prefs;
      final token = await getToken();
      final expiryStr = prefs.getString(_tokenExpiryKey);
      if (token == null || expiryStr == null) return null;
      return TokenData(
        token: token,
        expiresAt: DateTime.parse(expiryStr),
      );
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> hasToken() async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(_tokenKey);
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> hasActiveSession() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_sessionKey) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> setLoginData(Map<String, dynamic> loginData) async {
    try {
      final prefs = await _prefs;
      await Future.wait([
        prefs.setString(_loginDataKey, jsonEncode(loginData)),
        prefs.setBool(_sessionKey, true),
      ]);
    } on MissingPluginException {
      // Ignorar silenciosamente.
    }
  }

  Future<Map<String, dynamic>?> getLoginData() async {
    try {
      final prefs = await _prefs;
      final data = prefs.getString(_loginDataKey);
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await _prefs;
      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_tokenExpiryKey),
        prefs.remove(_loginDataKey),
        prefs.remove(_sessionKey),
      ]);
    } on MissingPluginException {
      // No-op.
    }
  }
}

class TokenData {
  final String token;
  final DateTime expiresAt;

  const TokenData({
    required this.token,
    required this.expiresAt,
  });
}
