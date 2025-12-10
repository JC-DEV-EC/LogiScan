import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/config/api_config.dart';
import 'core/services/http_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/secure_credentials_service.dart';
import 'core/services/version_service.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
