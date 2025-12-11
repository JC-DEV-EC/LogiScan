import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/message_helper.dart';
import '../../providers/auth_provider.dart';
import 'auth_page.dart';
import 'home_page.dart';
import 'scan_page.dart';
import '../../../scan/models/measurement_models.dart';
import '../../../scan/models/register_models.dart';
import '../../../scan/services/measurement_service.dart';

class ScanDetailsPage extends StatefulWidget {
  const ScanDetailsPage({super.key, required this.code});

  final String code;

  @override
  State<ScanDetailsPage> createState() => _ScanDetailsPageState();
}

class _ScanDetailsPageState extends State<ScanDetailsPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  bool _isProcessingMeasurements = false;
  bool _isSavingPackage = false;

  @override
  void initState() {
    super.initState();
    _codeController.text = widget.code;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _addImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _images.add(image);
    });
  }

  Future<void> _handleMeasurementCapture() async {
    final measurementService = context.read<MeasurementService>();

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      _isProcessingMeasurements = true;
    });

    try {
      final bytes = await photo.readAsBytes();
      final encoded = base64Encode(bytes);
      final fileName = photo.name;
      final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';

      final request = ProcessMeasurementDataRequest(
        file: RequestEncodeFile(
          encodeContent: encoded,
          fileExtension: ext,
          fileName: fileName,
        ),
      );

      final response = await measurementService.processMeasurementData(request);
      if (!mounted) return;

      if (response.isSuccessful && response.content != null) {
        final data = response.content!;

        setState(() {
          if (data.length != null) {
            _lengthController.text = _formatNumber(data.length!);
          }
          if (data.width != null) {
            _widthController.text = _formatNumber(data.width!);
          }
          if (data.height != null) {
            _heightController.text = _formatNumber(data.height!);
          }
          if (data.weight != null) {
            _weightController.text = _formatNumber(data.weight!);
          }
        });
      } else {
        final msg = response.messageDetail;
        if (mounted && msg != null && msg.isNotEmpty) {
          MessageHelper.showIconSnackBar(
            context,
            message: msg,
            isSuccess: false,
          );
        }
      }
    } catch (_) {
      // No local UI message: if backend didn't provide text, we fail silently here.
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingMeasurements = false;
        });
      }
    }
  }

  String _formatNumber(double value) =>
      value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);

  Future<void> _handleSavePackage() async {
    final measurementService = context.read<MeasurementService>();

    final tracking = _codeController.text.trim();
    final length = double.tryParse(_lengthController.text.trim());
    final width = double.tryParse(_widthController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (tracking.isEmpty ||
        length == null ||
        width == null ||
        height == null ||
        weight == null ||
        length <= 0 ||
        width <= 0 ||
        height <= 0 ||
        weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid dimensions and weight.'),
        ),
      );
      return;
    }

    setState(() {
      _isSavingPackage = true;
    });

    try {
      final List<RequestEncodeFile> encodedFiles = [];
      for (final img in _images) {
        final bytes = await File(img.path).readAsBytes();
        final encoded = base64Encode(bytes);
        final name = img.name;
        final ext = name.contains('.') ? name.split('.').last : 'jpg';
        encodedFiles.add(
          RequestEncodeFile(
            encodeContent: encoded,
            fileExtension: ext,
            fileName: name,
          ),
        );
      }

      final request = RegisterPackageRequest(
        trackingNumber: tracking,
        weight: weight,
        width: width,
        length: length,
        height: height,
        files: encodedFiles.isEmpty ? null : encodedFiles,
      );

      final response = await measurementService.registerPackage(request);
      if (!mounted) return;

      if (response.isSuccessful) {
        final userMessage = response.content?.userMessage;
        if (userMessage != null && userMessage.isNotEmpty) {
          MessageHelper.showIconSnackBar(
            context,
            message: userMessage,
            isSuccess: true,
          );
        }
        Navigator.of(context).pop();
      } else {
        final msg = response.messageDetail;
        if (msg != null && msg.isNotEmpty) {
          MessageHelper.showIconSnackBar(
            context,
            message: msg,
            isSuccess: false,
          );
        }
      }
    } catch (_) {
      // No local UI message: if backend didn't provide text, we fail silently here.
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPackage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      bottomNavigationBar: const _MainBottomNav(currentIndex: 1),
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Package details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // SCANNED CODE
                              const Text(
                                'Scanned code',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _codeController,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  hintText: 'Scanned code',
                                ),
                              ),

                              const SizedBox(height: 20),

                              // DIMENSIONS
                              const Text(
                                'Dimensions (inches)',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _NumberField(
                                      controller: _lengthController,
                                      label: 'Length',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _NumberField(
                                      controller: _widthController,
                                      label: 'Width',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _NumberField(
                                      controller: _heightController,
                                      label: 'Height',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // WEIGHT
                              const Text(
                                'Weight (lb)',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _NumberField(
                                controller: _weightController,
                                label: 'Weight',
                              ),

                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: _isProcessingMeasurements
                                      ? null
                                      : _handleMeasurementCapture,
                                  icon: _isProcessingMeasurements
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.photo_camera_outlined,
                                          size: 18,
                                        ),
                                  label: Text(
                                    _isProcessingMeasurements
                                        ? 'Processing...'
                                        : 'Read from label',
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // IMAGES
                              const Text(
                                'Images',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.image_outlined,
                                      color: Color(0xFF3F3F3F),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Add photos of the package',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    OutlinedButton.icon(
                                      onPressed: _addImageFromCamera,
                                      icon: const Icon(
                                        Icons.add_a_photo_outlined,
                                      ),
                                      label: const Text('Add images'),
                                    ),

                                    if (_images.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _images
                                              .map(
                                                (xfile) => ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.file(
                                                    File(xfile.path),
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // SAVE BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton(
                                  onPressed: _isSavingPackage
                                      ? null
                                      : _handleSavePackage,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isSavingPackage
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Save and continue'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  const _MainBottomNav({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF111111),
      unselectedItemColor: const Color(0xFF9CA3AF),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
      onTap: (index) async {
        if (index == currentIndex) return;

        if (index == 0) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ScanPage()),
            (route) => false,
          );
        } else if (index == 2) {
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

          if (shouldLogout == true) {
            await authProvider.logout();
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
            );
          }
        }
      },
    );
  }
}
