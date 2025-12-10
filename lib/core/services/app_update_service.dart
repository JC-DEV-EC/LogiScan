import 'package:flutter/material.dart';

import 'app_logger.dart';
import 'version_service.dart';

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  bool _isShowingUpdateDialog = false;

  Future<void> handleVersionResponse(
    BuildContext? context,
    VersionResponse versionResponse,
  ) async {
    if (context == null || !context.mounted) {
      AppLogger.log('Context not available for version dialog', source: 'AppUpdateService');
      return;
    }

    if (_isShowingUpdateDialog) return;

    if (versionResponse.updateRequired) {
      await _showForceUpdateDialog(context, versionResponse);
    } else if (versionResponse.updateAvailable) {
      await _showOptionalUpdateDialog(context, versionResponse);
    }
  }

  Future<void> _showForceUpdateDialog(
    BuildContext context,
    VersionResponse versionResponse,
  ) async {
    if (_isShowingUpdateDialog) return;
    _isShowingUpdateDialog = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {},
          child: AlertDialog(
            title: const Text('Actualización requerida'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  versionResponse.updateMessage ??
                      'Se requiere actualizar la aplicación para continuar.',
                ),
                const SizedBox(height: 12),
                if (versionResponse.minVersion != null)
                  Text(
                    'Versión mínima requerida: ${versionResponse.minVersion}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                Text(
                  'Versión actual: ${VersionService.instance.version}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );

    _isShowingUpdateDialog = false;
  }

  Future<void> _showOptionalUpdateDialog(
    BuildContext context,
    VersionResponse versionResponse,
  ) async {
    if (_isShowingUpdateDialog) return;
    _isShowingUpdateDialog = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Actualización disponible'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                versionResponse.updateMessage ??
                    'Hay una nueva versión de la aplicación disponible.',
              ),
              const SizedBox(height: 12),
              if (versionResponse.latestVersion != null)
                Text(
                  'Nueva versión: ${versionResponse.latestVersion}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              Text(
                'Versión actual: ${VersionService.instance.version}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Más tarde'),
            ),
          ],
        );
      },
    );

    _isShowingUpdateDialog = false;
  }
}
