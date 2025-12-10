import 'dart:ui';

import 'package:flutter/material.dart';
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

    return Scaffold(
      body: Stack(
        children: [
          // Fondo en degradado azul.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3F6DB0),
                  Color(0xFF274979),
                ],
              ),
            ),
          ),
          // Líneas decorativas suaves para un fondo más profesional.
          CustomPaint(
            size: Size.infinite,
            painter: _BackgroundLinesPainter(),
          ),
          // Figuras flotantes (círculos y cuadrados blancos) sobre el degradado.
          const _FloatingShapesLayer(),
          // Contenido principal.
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: size.width > 420 ? 380 : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          'LOGO',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                              ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: _isLogin
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          _isLogin ? 'Login' : 'Sign up',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlassContainer(
                        borderRadius: BorderRadius.circular(36),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: _AuthForm(
                          isLogin: _isLogin,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isLoading: auth.isLoading,
                          error: auth.error,
                          onToggle: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          onSubmit: () async {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            if (email.isEmpty || password.isEmpty) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Ingresa tu correo y contraseña'),
                                ),
                              );
                              return;
                            }

                            final success = await auth.login(email, password);
                            if (!mounted) return;
                            if (success) {
                              // Navegación diferida para evitar advertencia de contexto
                              WidgetsBinding.instance.addPostFrameCallback((_) {
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
    );
  }
}

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.75),
                Colors.white.withValues(alpha: 0.35),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
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
          hintText: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
        ),
        const SizedBox(height: 16),
        _GlassTextField(
          hintText: 'Password',
          icon: Icons.lock_outline,
          obscureText: true,
          controller: passwordController,
        ),
        if (isLogin) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          const _GlassTextField(
            hintText: 'Confirm password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF274979),
                  Color(0xFF1F3A5F),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isLogin ? 'Login' : 'Sign up',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (error != null && error!.isNotEmpty) ...[
          Builder(
            builder: (context) {
              final msg = error!;
              // Si el backend envía mensaje de versión mínima, mostrar diálogo de actualización
              if (msg.toLowerCase().contains('versión mínima') ||
                  msg.toLowerCase().contains('version minima')) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
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
                });
              } else {
                // Mostrar snackbar con icono (mismo concepto que MessageHelper en gbi_logistics)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  MessageHelper.showIconSnackBar(
                    context,
                    message: msg,
                    isSuccess: false,
                  );
                });
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: onToggle,
          child: Text.rich(
            TextSpan(
              text: isLogin
                  ? "Don't have an account? "
                  : 'Already have an account? ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: isLogin ? 'Sign up' : 'Login',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
  });

  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(30),
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          _GradientIconPill(icon: icon),
        ],
      ),
    );
  }
}

class _GradientIconPill extends StatelessWidget {
  const _GradientIconPill({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 52,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3F6DB0),
            Color(0xFF274979),
          ],
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}

class _FloatingShapesLayer extends StatelessWidget {
  const _FloatingShapesLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          _floatingCircle(left: 24, top: 80, size: 18),
          _floatingCircle(right: 32, top: 140, size: 12),
          _floatingCircle(left: 80, bottom: 160, size: 10),
          _floatingSquare(right: 40, bottom: 120, size: 22),
          _floatingSquare(left: 32, bottom: 80, size: 16),
        ],
      ),
    );
  }

  Positioned _floatingCircle({
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double size,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Positioned _floatingSquare({
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double size,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _BackgroundLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Pinceles para líneas finas y gruesas.
    final mainStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: 0.32);

    final softStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.18);

    final boldStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white.withValues(alpha: 0.40);

    // Líneas superiores suaves.
    final topWave1 = Path()
      ..moveTo(-80, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.02,
        size.width * 0.9,
        size.height * 0.18,
      );

    final topWave2 = Path()
      ..moveTo(-40, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.08,
        size.width * 1.05,
        size.height * 0.26,
      );

    // Banda diagonal central.
    final middleWave1 = Path()
      ..moveTo(-60, size.height * 0.46)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.38,
        size.width * 1.1,
        size.height * 0.52,
      );

    final middleWave2 = Path()
      ..moveTo(-40, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.50,
        size.width * 1.0,
        size.height * 0.64,
      );

    // Líneas inferiores largas.
    final bottomWave1 = Path()
      ..moveTo(-70, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.88,
        size.width * 0.98,
        size.height * 0.96,
      );

    final bottomWave2 = Path()
      ..moveTo(-30, size.height * 0.86)
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.96,
        size.width * 1.1,
        size.height * 1.04,
      );

    // Dibujar líneas con distintos grosores.
    canvas.drawPath(topWave1, mainStroke);
    canvas.drawPath(topWave2, softStroke);
    canvas.drawPath(middleWave1, boldStroke);
    canvas.drawPath(middleWave2, softStroke);
    canvas.drawPath(bottomWave1, mainStroke);
    canvas.drawPath(bottomWave2, softStroke);

    // Manchas suaves de color para dar profundidad.
    final accentPaint1 = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF94AEDD),
          Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromLTWH(
          size.width * 0.05,
          size.height * 0.55,
          size.width * 0.6,
          size.height * 0.35,
        ),
      );

    final accentBlob1 = Path()
      ..moveTo(size.width * 0.0, size.height * 0.70)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.60,
        size.width * 0.55,
        size.height * 0.74,
      )
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.95,
        size.width * 0.0,
        size.height * 0.92,
      )
      ..close();

    final accentPaint2 = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFB0C5F0),
          Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromLTWH(
          size.width * 0.35,
          size.height * 0.35,
          size.width * 0.5,
          size.height * 0.40,
        ),
      );

    final accentBlob2 = Path()
      ..moveTo(size.width * 0.40, size.height * 0.40)
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.38,
        size.width * 0.95,
        size.height * 0.50,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.60,
        size.width * 0.42,
        size.height * 0.58,
      )
      ..close();

    canvas.drawPath(accentBlob1, accentPaint1);
    canvas.drawPath(accentBlob2, accentPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
