import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/food/barcode_lookup.dart';
import '../../state/app_controller.dart';

/// Where a finished scan should go. A code already in the pantry opens that
/// bag. An EAN or UPC opens the product lookup. Anything else, including a
/// blank "pick a brand", opens confirm.
String scanDestination(AppController app, String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '/confirm';
  final bag = app.bagForBarcode(value);
  if (bag != null) return '/bag?id=${bag.item.id}';
  if (isRetailBarcode(value)) {
    return '/lookup?code=${Uri.encodeComponent(value)}';
  }
  return '/confirm?code=${Uri.encodeComponent(value)}';
}

/// What to say when the camera cannot start. The buttons under the
/// viewfinder stay usable either way.
String scanCameraMessage(MobileScannerErrorCode? code) {
  return switch (code) {
    MobileScannerErrorCode.permissionDenied => '没有相机权限。可以在系统设置里打开，也可以选品牌或拍包装。',
    MobileScannerErrorCode.unsupported => '这台手机扫不了码。可以选品牌，或拍包装。',
    _ => '相机没开',
  };
}

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

/// One scan screen. Empty reads and bad check digits do not lock the camera.
class ScanSession {
  var handled = false;

  /// The code to open, or null when this read should be ignored.
  String? take(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    if (handled) return null;
    if (isGtinLength(value) && !hasGtinChecksum(value)) return null;
    handled = true;
    return value;
  }
}

/// Null when [raw] is an EAN-8, UPC-A, EAN-13 or GTIN-14 with a good check digit.
String? manualBarcodeError(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '写上包装上的数字';
  if (!isGtinLength(digits)) return '需要 8、12、13 或 14 位';
  if (!hasGtinChecksum(digits)) return '校验没通过，再对一下末位';
  return null;
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController? _camera;
  final _session = ScanSession();
  var _torchOn = false;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: '返回',
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      fixedSize: const Size(48, 48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.of(context).onScrim,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: '手电筒',
                    onPressed: _toggleTorch,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      fixedSize: const Size(48, 48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    icon: Icon(
                      _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                      color: AppColors.of(context).onScrim,
                    ),
                  ),
                ],
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
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _typeCode,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.of(context).onScrim,
                        side: BorderSide(color: AppColors.of(context).onScrim),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('手输条码'),
                    ),
                    TextButton(
                      onPressed: () => _openConfirm(''),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.of(context).onScrim,
                        minimumSize: const Size(48, 48),
                      ),
                      child: const Text('选品牌'),
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
      placeholderBuilder: (context) => const SizedBox.expand(),
      errorBuilder: (context, error) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            scanCameraMessage(error.errorCode),
            textAlign: TextAlign.center,
            style: zhuaji.copyWith(color: AppColors.of(context).onScrim),
          ),
        ),
      ),
      onDetect: (capture) {
        final raw = capture.barcodes
            .map((code) => code.rawValue)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .firstOrNull;
        final taken = _session.take(raw);
        if (taken != null) _openConfirm(taken);
      },
    );
  }

  Future<void> _toggleTorch() async {
    final camera = _camera;
    if (camera == null) return;
    try {
      await camera.toggleTorch();
      if (!mounted) return;
      setState(() => _torchOn = !_torchOn);
    } catch (_) {}
  }

  Future<void> _typeCode() async {
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _ManualBarcodeDialog(),
    );
    if (code == null || !mounted) return;
    await _openConfirm(code);
  }

  Future<void> _openConfirm(String value) async {
    if (value.isEmpty) {
      if (_session.handled) return;
      _session.handled = true;
    } else if (!_session.handled) {
      final taken = _session.take(value);
      if (taken == null) return;
      value = taken;
    }
    try {
      await _camera?.stop();
    } catch (_) {}
    if (!mounted) return;
    final app = AppScope.of<AppController>(context);
    context.pushReplacement(scanDestination(app, value));
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

class _ManualBarcodeDialog extends StatefulWidget {
  const _ManualBarcodeDialog();

  @override
  State<_ManualBarcodeDialog> createState() => _ManualBarcodeDialogState();
}

class _ManualBarcodeDialogState extends State<_ManualBarcodeDialog> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    final error = manualBarcodeError(_code.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, _code.text.replaceAll(RegExp(r'\D'), ''));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('手输条码'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _code,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '包装上的数字'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: zhuaji.copyWith(color: AppColors.of(context).danger),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('查看')),
      ],
    );
  }
}
