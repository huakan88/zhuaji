import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/food/barcode_lookup.dart';
import '../../state/app_controller.dart';

class LookupPage extends StatefulWidget {
  const LookupPage({required this.code, super.key});

  final String code;

  @override
  State<LookupPage> createState() => _LookupPageState();
}

class _LookupPageState extends State<LookupPage> {
  BarcodeRecord? _record;
  var _loading = true;
  var _saving = false;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh && mounted) setState(() => _loading = true);
    final app = AppScope.of<AppController>(context);
    final BarcodeRecord record;
    try {
      record = await app.resolveBarcode(widget.code, refresh: refresh);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _record = BarcodeRecord.offline(widget.code);
        _loading = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _record = record;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('商品'),
      body: _loading || record == null
          ? const Center(child: _Loading())
          : record.found
          ? _Hit(
              record: record,
              saving: _saving,
              onSave: _save,
              code: widget.code,
            )
          : _Miss(
              offline: record.offline,
              incomplete: record.incomplete,
              onRetry: () => _load(refresh: true),
              code: widget.code,
            ),
    );
  }

  Future<void> _save() async {
    final record = _record;
    if (record == null || !record.found || _saving) return;
    setState(() => _saving = true);
    final app = AppScope.of<AppController>(context);
    final id = await app.adoptBarcode(record);
    if (!mounted) return;
    final code = Uri.encodeComponent(widget.code.trim());
    context.pushReplacement('/confirm?code=$code&product=$id');
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(
          '正在查这个条码',
          style: zhuaji.copyWith(color: AppColors.of(context).muted),
        ),
      ],
    );
  }
}

class _Hit extends StatelessWidget {
  const _Hit({
    required this.record,
    required this.saving,
    required this.onSave,
    required this.code,
  });

  final BarcodeRecord record;
  final bool saving;
  final VoidCallback onSave;
  final String code;

  @override
  Widget build(BuildContext context) {
    final source = record.sourceLabel;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        if (record.imageUrl != null) ...[
          _Photo(url: record.imageUrl!),
          const SizedBox(height: 16),
        ],
        if (record.brand.isNotEmpty)
          Text(
            record.brand,
            style: zhuaji.copyWith(
              fontSize: 13,
              color: AppColors.of(context).muted,
            ),
          ),
        Text(
          record.name,
          style: zhuaji.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        if (record.quantity.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(record.quantity, style: zhuaji.copyWith(fontSize: 15)),
        ],
        const SizedBox(height: 4),
        Text(
          code,
          style: zhuaji.copyWith(
            fontSize: 12,
            color: AppColors.of(context).muted,
          ),
        ),
        if (record.ingredients.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionLabel('配料'),
          const SizedBox(height: 8),
          Text(
            record.ingredients,
            style: zhuaji.copyWith(fontSize: 14, height: 1.45),
          ),
        ],
        if (record.nutrients.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionLabel('成分'),
          const SizedBox(height: 8),
          for (final item in record.nutrients)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: Text(item.label, style: zhuaji)),
                  Text(
                    item.text,
                    style: zhuaji.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
        if (source.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _lookupNote(record, source),
            style: zhuaji.copyWith(
              fontSize: 12,
              height: 1.4,
              color: AppColors.of(context).muted,
            ),
          ),
          if (record.source == 'productguru' &&
              (record.sourceUrl ?? '').isNotEmpty)
            Text(
              'Data: ProductGuru  ${record.sourceUrl}',
              style: zhuaji.copyWith(
                fontSize: 12,
                height: 1.4,
                color: AppColors.of(context).muted,
              ),
            ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: saving ? null : onSave,
          child: const Text('收进粮仓'),
        ),
        TextButton(
          onPressed: () {
            final encoded = Uri.encodeComponent(code.trim());
            context.push('/confirm?code=$encoded&blank=1');
          },
          child: const Text('不是这款'),
        ),
      ],
    );
  }
}

class _Miss extends StatelessWidget {
  const _Miss({
    required this.offline,
    required this.incomplete,
    required this.onRetry,
    required this.code,
  });

  final bool offline;
  final bool incomplete;
  final VoidCallback onRetry;
  final String code;

  @override
  Widget build(BuildContext context) {
    final encoded = Uri.encodeComponent(code.trim());
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          offline ? '没连上公开商品库' : '公开库里没有这款',
          style: zhuaji.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          offline
              ? '可以再试一次。也可以拍包装上的字，或点选品牌，记下后下次扫到就能认出。'
              : incomplete
              ? '已经回应的库里没有这款，还有库这次没连上。国产粮经常要拍包装。可以再查一次，或点选品牌，结果会记在这台手机上。'
              : '进口粮多半能查到。国产粮经常不在这些免密钥的库里。拍包装认品牌和配料，或点选品牌，结果会记在这台手机上。',
          style: zhuaji.copyWith(
            fontSize: 14,
            height: 1.45,
            color: AppColors.of(context).muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          code,
          style: zhuaji.copyWith(
            fontSize: 12,
            color: AppColors.of(context).muted,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.push('/food?shot=1&bag=1&code=$encoded'),
          child: const Text('拍包装识别'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.push('/confirm?code=$encoded&blank=1'),
          child: const Text('选品牌'),
        ),
        TextButton(onPressed: onRetry, child: const Text('再查一次')),
      ],
    );
  }
}

String _lookupNote(BarcodeRecord record, String source) {
  final when = record.updatedAt;
  final day = when == null
      ? ''
      : '修正于 ${when.toUtc().toIso8601String().substring(0, 10)}。';
  return switch (record.source) {
    'user' => '这是你之前记下的。$day以包装为准。',
    'share' => '来自共享库。$day以包装为准。',
    'local' => '来自本机常见猫粮。名称和规格来自公开条码页，以包装为准。',
    _ => '来自 $source。公开资料，以包装为准。',
  };
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.l),
      child: ColoredBox(
        color: AppColors.of(context).field,
        child: SizedBox(height: 220, width: double.infinity, child: _image()),
      ),
    );
  }

  Widget _image() {
    final fallback = const Center(child: Text('没有图片'));
    if (url.startsWith('http')) {
      if (Platform.environment['FLUTTER_TEST'] == 'true') return fallback;
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    final path = url.startsWith('file:') ? Uri.parse(url).toFilePath() : url;
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return fallback;
  }
}
