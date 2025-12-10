import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static VersionService? _instance;
  static VersionService get instance => _instance ??= VersionService._();

  VersionService._();

  PackageInfo? _packageInfo;

  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      debugPrint('VersionService initialized: $fullVersion');
    } catch (e) {
      debugPrint('Error initializing VersionService: $e');
      _packageInfo = PackageInfo(
        version: '1.0.0',
        buildNumber: '9',
        appName: 'LogiScan',
        packageName: 'com.example.logiscan',
      );
    }
  }

  String get fullVersion {
    if (_packageInfo == null) return '1.0.0+1';
    return '${_packageInfo!.version}+${_packageInfo!.buildNumber}';
  }

  String get version {
    if (_packageInfo == null) return '1.0.0.9';
    return '${_packageInfo!.version}.${_packageInfo!.buildNumber}';
  }

  String get buildNumber {
    if (_packageInfo == null) return '9';
    return _packageInfo!.buildNumber;
  }

  String get platform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  Map<String, String> get versionHeaders => {
    'X-App-Version': version,
    'X-App-Build': buildNumber,
    'X-App-Platform': platform,
    'X-Client-Type': 'mobile-app',
  };
}

class VersionResponse {
  final bool updateRequired;
  final bool updateAvailable;
  final String? minVersion;
  final String? latestVersion;
  final String? updateMessage;
  final String? updateUrl;

  VersionResponse({
    required this.updateRequired,
    this.updateAvailable = false,
    this.minVersion,
    this.latestVersion,
    this.updateMessage,
    this.updateUrl,
  });

  factory VersionResponse.fromHeaders(Map<String, String> headers) {
    return VersionResponse(
      updateRequired: headers['X-Update-Required']?.toLowerCase() == 'true',
      updateAvailable: headers['X-Update-Available']?.toLowerCase() == 'true',
      minVersion: headers['X-Min-Version'],
      latestVersion: headers['X-Latest-Version'],
      updateMessage: headers['X-Update-Message'],
      updateUrl: headers['X-Update-URL'],
    );
  }
}
