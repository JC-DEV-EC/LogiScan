import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'auth_page.dart';
import 'scan_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.loginData;

    final fullName =
        '${user?.personFirstName ?? ''} ${user?.personLastName ?? ''}'.trim();
    final displayName = fullName.isEmpty ? 'LogiScan user' : fullName;
    final entityName = user?.entityName ?? 'No company specified';

    Future<void> handleSignOut() async {
      final navigator = Navigator.of(context);
      final authProvider = context.read<AuthProvider>();

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

      await authProvider.logout();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF101010),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        bottomNavigationBar: _HomeBottomNav(
          onScanTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ScanDetailsPage(code: ''),
              ),
            );
          },
          onLogoutTap: handleSignOut,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _DarkHeader(displayName: displayName, entityName: entityName),
              // Chip de escaneo centrado, levemente solapado con el header
              Transform.translate(
                offset: const Offset(0, -18),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _ScanActionChip(),
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_FunctionalitySection(), SizedBox(height: 24)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkHeader extends StatelessWidget {
  const _DarkHeader({required this.displayName, required this.entityName});

  final String displayName;
  final String entityName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 220,
                    child: Text(
                      'Welcome back',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 220,
                    child: Text(
                      entityName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.circle, size: 8, color: Color(0xFF16A34A)),
                      SizedBox(width: 6),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Account overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(4),
      child: const Icon(Icons.person, color: Colors.black87, size: 24),
    );
  }
}

class _ScanActionChip extends StatelessWidget {
  const _ScanActionChip();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ScanDetailsPage(code: '')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Scan packages',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Open the camera to scan labels and barcodes.',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF111827)),
          ],
        ),
      ),
    );
  }
}

class _FunctionalitySection extends StatelessWidget {
  const _FunctionalitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'LogiScan today',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        // Temporarily hide field scanning workspace (_TodayOverviewCard)
        const _ScannerTipsCard(),
      ],
    );
  }
}

/// Extra explanation card about how scanning works.
class _ScannerTipsCard extends StatelessWidget {
  const _ScannerTipsCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'How scanning works',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          _ScannerTipRow(
            icon: Icons.center_focus_strong,
            text:
                'Align the code inside the frame. The scan is automatic—no need to tap.',
          ),
          SizedBox(height: 6),
          _ScannerTipRow(
            icon: Icons.note_alt_outlined,
            text:
                'On the next screen, confirm dimensions and weight before saving.',
          ),
          SizedBox(height: 6),
          _ScannerTipRow(
            icon: Icons.camera_alt_outlined,
            text:
                'Add at least one photo per package to avoid claims and disputes.',
          ),
        ],
      ),
    );
  }
}

class _ScannerTipRow extends StatelessWidget {
  const _ScannerTipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF111827)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav({required this.onScanTap, required this.onLogoutTap});

  final VoidCallback onScanTap;
  final Future<void> Function() onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF111111),
      unselectedItemColor: const Color(0xFF9CA3AF),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
      currentIndex: 0,
      onTap: (index) async {
        if (index == 1) {
          onScanTap();
        } else if (index == 2) {
          await onLogoutTap();
        }
      },
    );
  }
}
