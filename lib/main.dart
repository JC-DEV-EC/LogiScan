import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/config/api_config.dart';
import 'core/services/http_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/secure_credentials_service.dart';
import 'core/services/version_service.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/scan/services/measurement_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  await VersionService.instance.initialize();
  runApp(const LogiScanApp());
}

class LogiScanApp extends StatefulWidget {
  const LogiScanApp({super.key});

  @override
  State<LogiScanApp> createState() => _LogiScanAppState();
}

class _LogiScanAppState extends State<LogiScanApp> {
  late final StorageService _storageService;
  late final HttpService _httpService;
  late final SecureCredentialsService _secureCredentialsService;
  late final AuthService _authService;
  late final MeasurementService _measurementService;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _secureCredentialsService = SecureCredentialsService();
    _httpService = HttpService(
      baseUrl: ApiConfig.baseUrl,
      onSessionExpired: () {
        // Por ahora solo limpiamos el token; la UI puede reaccionar via AuthProvider.
      },
    );
    _authService =
        AuthService(_httpService, _storageService, _secureCredentialsService);
    _measurementService = MeasurementService(_httpService);

    _httpService.tokenRefreshCallback = () async {
      return await _authService.refreshTokenIfNeeded();
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(_authService),
        ),
        Provider<MeasurementService>(
          create: (_) => _measurementService,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LogiScan',
        theme: AppTheme.lightTheme,
        home: const AuthScreen(),
      ),
    );
  }
}
