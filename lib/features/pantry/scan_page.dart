import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_fonts.dart';

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
                            style: zhuaji.copyWith(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '条码',
                              labelStyle: zhuaji.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () => _finish(_manual.text),
                            child: const Text('确定'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _manualOpen = true),
                            child: Text(
                              '手输',
                              style: zhuaji.copyWith(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _openConfirm(''),
                            child: Text(
                              '没扫到',
                              style: zhuaji.copyWith(color: Colors.white),
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
      child: Text('相机没开', style: zhuaji.copyWith(color: Colors.white)),
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
      await _openConfirm('');
      return;
    }
    await _openConfirm(value);
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
