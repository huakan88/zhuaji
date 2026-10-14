import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class DewormsPage extends StatefulWidget {
  const DewormsPage({super.key});

  @override
  State<DewormsPage> createState() => _DewormsPageState();
}

class _DewormsPageState extends State<DewormsPage> {
  static const _products = ['大宠爱', '博来恩', '海乐妙'];
  var _kind = DewormKind.internal;
  var _product = '大宠爱';
  DateTime? _given;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: zhuajiBar('驱虫'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final given = _given ??= dateOnly(app.now);
    final next = given.add(const Duration(days: 90));
    final items = [...app.catDeworms]
      ..sort((a, b) {
        final left = a.nextDue ?? a.givenOn;
        final right = b.nextDue ?? b.givenOn;
        return left.compareTo(right);
      });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('驱虫'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          if (items.isEmpty)
            Text('还没记', style: zhuaji.copyWith(color: AppColors.muted))
          else
            for (final item in items.take(3)) _Record(item: item),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('体内'),
                selected: _kind == DewormKind.internal,
                selectedColor: AppColors.coral,
                onSelected: (_) => setState(() => _kind = DewormKind.internal),
              ),
              ChoiceChip(
                label: const Text('体外'),
                selected: _kind == DewormKind.external,
                selectedColor: AppColors.coral,
                onSelected: (_) => setState(() => _kind = DewormKind.external),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final label in _products)
                ChoiceChip(
                  label: Text(label),
                  selected: _product == label,
                  selectedColor: AppColors.coral,
                  onSelected: (_) => setState(() => _product = label),
                ),
            ],
          ),
          DateLine(
            label: '使用',
            date: given,
            onTap: () async {
              final picked = await pickDate(context, given);
              if (picked == null) return;
              setState(() => _given = dateOnly(picked));
            },
          ),
          Text(
            '下次 ${formatDate(next)}',
            style: zhuaji.copyWith(color: AppColors.muted),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await app.saveDeworm(
                      DewormDraft(
                        catId: cat.id,
                        kind: _kind,
                        product: _product,
                        givenOn: given,
                        nextDue: next,
                      ),
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (!context.mounted) return;
                    showMessage(context, '记下了');
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('记下'),
          ),
        ),
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({required this.item});

  final DewormRecord item;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final due = item.nextDue;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: zhuaji.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                due == null
                    ? dewormLabel(item.kind)
                    : '${dewormLabel(item.kind)} · ${countdownOf(due, app.now)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: zhuaji.copyWith(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            final next = await app.completeDeworm(item);
            if (!context.mounted) return;
            showMessage(context, '下次 ${formatDate(next)}');
          },
          child: const Text('完成'),
        ),
        TextButton(
          onPressed: () async {
            if (!await confirmDelete(context, '删掉这次？')) return;
            await app.removeDeworm(item.id);
          },
          child: const Text('删除'),
        ),
      ],
    );
  }
}
