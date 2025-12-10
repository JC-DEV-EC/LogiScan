import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'auth_page.dart';
import 'scan_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.loginData;

    final fullName =
        '${user?.personFirstName ?? ''} ${user?.personLastName ?? ''}'.trim();
    final displayName =
        fullName.isEmpty ? 'LogiScan user' : fullName;
    final entityName = user?.entityName ?? 'No company specified';

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado azul
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
          // Burbujas suaves en el fondo
          const _DashboardBackgroundDecor(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Sign out',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Sign out'),
                                  content: const Text(
                                    'You are about to sign out of your account. Do you want to continue?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Sign out'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldLogout != true) return;

                              await context.read<AuthProvider>().logout();
                              if (!context.mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const AuthScreen(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tarjeta de usuario (liquid glass)
                  _GlassPanel(
                    borderRadius: BorderRadius.circular(32),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: _UserLogo(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entityName,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tarjeta principal de acción: Escanear paquetes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _GlassPanel(
                          borderRadius: BorderRadius.circular(32),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Operations',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(Icons.more_horiz,
                                      color: Colors.black45),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Botón grande de escanear paquetes
                              _ScanCard(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Aquí podríamos agregar más panels de estadísticas en el futuro
                        Expanded(
                          child: Row(
                            children: const [
                              Expanded(child: _MiniStatCard(label: 'Guides today')),
                              SizedBox(width: 16),
                              Expanded(child: _MiniStatCard(label: 'Scanned packages')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
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
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
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

class _UserLogo extends StatelessWidget {
  const _UserLogo();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().loginData;
    final logoUrl = user?.courierImageUrl;

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          logoUrl,
          width: 44,
          height: 44,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) {
            return const Icon(
              Icons.person_outline,
              color: Color(0xFF274979),
            );
          },
        ),
      );
    }

    return const Icon(
      Icons.person_outline,
      color: Color(0xFF274979),
    );
  }
}


class _ScanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF42A5F5),
                  Color(0xFF1976D2),
                ],
              ),
            ),
            child: const Icon(Icons.qr_code_scanner,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Scan packages',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Start a new scan of guides and packages.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScanPage(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded,
                color: Color(0xFF274979)),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '--',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBackgroundDecor extends StatelessWidget {
  const _DashboardBackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -60,
            child: _circle(140, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 80,
            right: -30,
            child: _circle(90, Colors.white.withValues(alpha: 0.10)),
          ),
          Positioned(
            bottom: -50,
            right: -40,
            child: _circle(150, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: 40,
            left: -20,
            child: _circle(80, Colors.white.withValues(alpha: 0.10)),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
