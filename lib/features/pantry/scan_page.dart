import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/widgets/common.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController? _camera;
  final _manual = TextEditingController();
  var _handled = false;
  var _manualOpen = false;

  @override
  void dispose() {
    _camera?.dispose();
    _manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _cameraPane()),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _manualOpen
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _manual,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: '条码',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () => _finish(_manual.text),
                            child: const Text('确定'),
                          ),
                        ],
                      )
                    : TextButton(
                        onPressed: () => setState(() => _manualOpen = true),
                        child: const Text(
                          '手输',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPane() {
    const fallback = Center(
      child: Text('相机没开', style: TextStyle(color: Colors.white)),
    );
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
      showMessage(context, '还没扫到');
      return;
    }
    _handled = true;
    try {
      await _camera?.stop();
    } catch (_) {}
    if (!mounted) return;
    context.pushReplacement('/confirm?code=${Uri.encodeComponent(value)}');
  }
}
