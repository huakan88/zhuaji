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
  final _camera = MobileScannerController();
  final _manual = TextEditingController();
  var _handled = false;

  @override
  void dispose() {
    _camera.dispose();
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
          Expanded(
            child: MobileScanner(
              controller: _camera,
              onDetect: (capture) {
                final raw = capture.barcodes
                    .map((code) => code.rawValue)
                    .whereType<String>()
                    .where((value) => value.trim().isNotEmpty)
                    .firstOrNull;
                if (raw != null) _finish(raw);
              },
            ),
          ),
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

  Future<void> _finish(String raw) async {
    final value = raw.trim();
    if (_handled || value.isEmpty) return;
    _handled = true;
    await _camera.stop();
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
