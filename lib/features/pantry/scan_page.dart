import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';

/// Formats the camera is asked to read. EAN and UPC are the barcodes on
/// bags; DataBar, DataMatrix and QR cover GS1 (including Digital Link).
const scanFormats = <BarcodeFormat>[
  BarcodeFormat.ean13,
  BarcodeFormat.ean8,
  BarcodeFormat.upcA,
  BarcodeFormat.upcE,
  BarcodeFormat.dataBar,
  BarcodeFormat.dataBarExpanded,
  BarcodeFormat.dataBarLimited,
  BarcodeFormat.qrCode,
  BarcodeFormat.dataMatrix,
  BarcodeFormat.code128,
];

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController? _camera;
  var _handled = false;

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).scrim,
      body: Stack(
        children: [
          Positioned.fill(child: _cameraPane()),
          const IgnorePointer(child: _Viewfinder()),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.close, color: AppColors.of(context).onScrim),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '条形码、二维码都能扫',
                      style: zhuaji.copyWith(
                        color: AppColors.of(context).onScrim,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EAN、UPC、GS1 和二维码',
                      style: zhuaji.copyWith(
                        color: AppColors.of(context).onScrimMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.push('/food?shot=1&bag=1'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('拍包装识别'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.push('/food?bag=1'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.of(context).onScrim,
                        side: BorderSide(color: AppColors.of(context).onScrim),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('自己添加'),
                    ),
                    TextButton(
                      onPressed: () => _openConfirm(''),
                      child: Text(
                        '选品牌',
                        style: zhuaji.copyWith(
                          color: AppColors.of(context).onScrim,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPane() {
    final fallback = Center(
      child: Text(
        '相机没开',
        style: zhuaji.copyWith(color: AppColors.of(context).onScrim),
      ),
    );
    if (Platform.environment['FLUTTER_TEST'] == 'true') return fallback;
    final camera = _camera ??= MobileScannerController(formats: scanFormats);
    return MobileScanner(
      controller: camera,
      errorBuilder: (context, error) => fallback,
      onDetect: (capture) {
        final raw = capture.barcodes
            .map((code) => code.rawValue)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .firstOrNull;
        if (raw != null) _openConfirm(raw);
      },
    );
  }

  Future<void> _openConfirm(String value) async {
    if (_handled) return;
    _handled = true;
    try {
      await _camera?.stop();
    } catch (_) {}
    if (!mounted) return;
    final query = value.isEmpty ? '' : '?code=${Uri.encodeComponent(value)}';
    context.pushReplacement('/confirm$query');
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.of(context).onScrim, width: 1.5),
        ),
      ),
    );
  }
}
