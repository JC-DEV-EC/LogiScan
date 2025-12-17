import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../pages/home_page.dart';
import '../../../../core/presentation/message_helper.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/services/version_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _didAutoRedirect = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    // Redirect if session already active
    if (auth.isAuthenticated && !_didAutoRedirect) {
      _didAutoRedirect = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF050505), Color(0xFF222222)],
                ),
              ),
            ),

            // Background decorative blocks
            const _BackgroundBlocks(),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: size.width > 420 ? 380 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),

                        // Logo
                        Center(
                          child: SizedBox(
                            width: size.width * 0.5,
                            height: 140,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Subtitle only
                        Center(
                          child: Text(
                            _isLogin
                                ? 'Sign in to continue'
                                : 'Create an account',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Auth card
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 20,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: _AuthForm(
                            isLogin: _isLogin,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: auth.isLoading,
                            error: auth.error,
                            onToggle: () {
                              setState(() => _isLogin = !_isLogin);
                            },
                            onSubmit: () async {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;

                              if (email.isEmpty || password.isEmpty) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ingresa tu correo y contraseña',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final success = await auth.login(email, password);

                              if (!mounted) return;
                              if (success) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const HomePage(),
                                    ),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundBlocks extends StatelessWidget {
  const _BackgroundBlocks();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              // Large diagonal panel across the center
              Positioned(
                top: height * 0.10,
                left: -width * 0.4,
                right: -width * 0.2,
                child: Transform.rotate(
                  angle: -0.35,
                  alignment: Alignment.center,
                  child: Container(
                    height: height * 0.45,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF171717), Color(0xFF0F0F0F)],
                      ),
                    ),
                  ),
                ),
              ),

              // Slightly lighter diagonal panel underneath
              Positioned(
                top: height * 0.30,
                left: -width * 0.3,
                right: -width * 0.3,
                child: Transform.rotate(
                  angle: -0.35,
                  alignment: Alignment.center,
                  child: Container(
                    height: height * 0.35,
                    decoration: const BoxDecoration(color: Color(0xFF262626)),
                  ),
                ),
              ),

              // Narrow darker strip to add depth
              Positioned(
                top: height * 0.05,
                left: -width * 0.5,
                right: width * 0.1,
                child: Transform.rotate(
                  angle: -0.35,
                  alignment: Alignment.center,
                  child: Container(
                    height: height * 0.20,
                    color: const Color(0xFF101010),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.isLogin,
    required this.onToggle,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.isLoading,
    this.error,
  });

  final bool isLogin;
  final VoidCallback onToggle;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLogin) ...[
          const _GlassTextField(
            hintText: 'User name',
            icon: Icons.person,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
        ],

        _GlassTextField(
          hintText:
              ''
              'Username',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
          onChanged: (_) {
            context.read<AuthProvider>().clearError();
          },
        ),

        const SizedBox(height: 16),

        _GlassTextField(
          hintText: 'Password',
          icon: Icons.lock_outline,
          obscureText: true,
          controller: passwordController,
          onChanged: (_) {
            context.read<AuthProvider>().clearError();
          },
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: isLoading ? null : onSubmit,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        if (error != null && error!.isNotEmpty) ...[
          Builder(
            builder: (context) {
              final msg = error!;

              final isVersionError =
                  msg.toLowerCase().contains('versión mínima') ||
                  msg.toLowerCase().contains('version minima');

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (isVersionError) {
                  AppUpdateService.instance.handleVersionResponse(
                    context,
                    VersionResponse(
                      updateRequired: true,
                      minVersion: null,
                      latestVersion: null,
                      updateMessage: msg,
                      updateUrl: null,
                    ),
                  );
                } else {
                  MessageHelper.showIconSnackBar(
                    context,
                    message: msg,
                    isSuccess: false,
                  );
                }
              });

              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 8),

        Text(
          'Version ${VersionService.instance.version}',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.onChanged,
  });

  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.grey.shade300,
          selectionColor: Colors.grey.withOpacity(0.4),
          selectionHandleColor: Colors.grey.shade300,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          filled: false,
        ),
      ),
    );
  }
}
