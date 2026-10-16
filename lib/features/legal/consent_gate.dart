import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import 'legal_copy.dart';
import 'legal_page.dart';

enum _ConsentSheet { welcome, privacy, agreement, permissions }

/// First-launch choice. Back from a document returns here. Back on the
/// welcome sheet does not enter the app.
class ConsentGate extends StatefulWidget {
  const ConsentGate({required this.onAccept, required this.onBasic, super.key});

  final Future<void> Function() onAccept;
  final Future<void> Function() onBasic;

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  _ConsentSheet _sheet = _ConsentSheet.welcome;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _sheet == _ConsentSheet.welcome) return;
        setState(() => _sheet = _ConsentSheet.welcome);
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: _sheet == _ConsentSheet.welcome
            ? null
            : AppBar(
                title: Text(_title),
                toolbarHeight: 56,
                leadingWidth: 88,
                leading: TextButton(
                  onPressed: () =>
                      setState(() => _sheet = _ConsentSheet.welcome),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: const Text('返回'),
                ),
              ),
        body: switch (_sheet) {
          _ConsentSheet.welcome => _welcome(context),
          _ConsentSheet.privacy => LegalBody(sections: privacySections),
          _ConsentSheet.agreement => LegalBody(sections: agreementSections),
          _ConsentSheet.permissions => LegalBody(sections: permissionSections),
        },
      ),
    );
  }

  String get _title {
    return switch (_sheet) {
      _ConsentSheet.privacy => '隐私政策',
      _ConsentSheet.agreement => '用户协议',
      _ConsentSheet.permissions => '权限说明',
      _ConsentSheet.welcome => '',
    };
  }

  Widget _welcome(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: BrandMark(size: 120)),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '欢迎使用花爪',
                style: zhuaji.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '猫咪的喂养和健康记录默认只留在这台手机上。'
              '请先阅读隐私政策和用户协议。同意之前不会初始化通知、扫码或联网，'
              '也不会申请相机、相册和通知权限。',
              style: zhuaji.copyWith(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                _link('隐私政策', _ConsentSheet.privacy),
                _link('用户协议', _ConsentSheet.agreement),
                _link('权限说明', _ConsentSheet.permissions),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: _busy ? null : () => _run(widget.onAccept),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('同意并继续'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _run(widget.onBasic),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('不同意，仅用基本功能'),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: _busy ? null : SystemNavigator.pop,
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: const Text('退出应用'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _link(String label, _ConsentSheet sheet) {
    return TextButton(
      onPressed: () => setState(() => _sheet = sheet),
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      child: Text(label),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
