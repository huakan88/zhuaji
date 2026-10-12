import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/copy.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({required this.mode, super.key});

  final String mode;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController? _camera;
  final _manual = TextEditingController();
  var _handled = false;

  @override
  void dispose() {
    _camera?.dispose();
    _manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs1 = widget.mode == 'gs1';
    return Scaffold(
      appBar: AppBar(title: Text(gs1 ? '扫描日期码' : '扫描商品条码')),
      body: Column(
        children: [
          Expanded(child: _cameraPane()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  gs1 ? '把 GS1 二维码或 DataMatrix 放进画面，也可以粘贴内容。' : kBarcodeNote,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _manual,
                  decoration: InputDecoration(
                    hintText: gs1 ? '(11)251012(17)270412(10)LOT' : '手动输入条码',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _finish(_manual.text),
                  child: const Text('使用这段内容'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPane() {
    const fallback = Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '相机暂时不可用。可以在下面手动输入条码或 GS1 内容。',
          textAlign: TextAlign.center,
        ),
      ),
    );
    // Widget tests have no camera implementation. Manual entry still works.
    if (Platform.environment['FLUTTER_TEST'] == 'true') return fallback;
    final camera = _camera ??= MobileScannerController();
    return MobileScanner(
      controller: camera,
      errorBuilder: (context, error) => fallback,
      onDetect: (capture) {
        final raw = capture.barcodes
            .map((code) => code.rawValue)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .firstOrNull;
        if (raw != null) _finish(raw);
      },
    );
  }

  Future<void> _finish(String raw) async {
    final value = raw.trim();
    if (_handled) return;
    if (value.isEmpty) {
      showMessage(context, '先扫到一条内容，或在下面输入');
      return;
    }
    _handled = true;
    try {
      await _camera?.stop();
    } catch (_) {
      // 相机没起来时仍然可以用手动结果。
    }
    if (!mounted) return;
    if (widget.mode == 'gs1') {
      context.pop(value);
      return;
    }
    final app = AppScope.of<AppController>(context);
    final product = app.findBarcode(value);
    if (!mounted) return;
    if (product == null) {
      context.pushReplacement('/product-form?barcode=${Uri.encodeComponent(value)}');
    } else {
      context.pushReplacement('/product?productId=${product.id}');
    }
  }
}
