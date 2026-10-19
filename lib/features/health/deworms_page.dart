import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';
import 'known_or_custom.dart';
import 'need_cat.dart';

class DewormsPage extends StatefulWidget {
  const DewormsPage({super.key});

  @override
  State<DewormsPage> createState() => _DewormsPageState();
}

class _DewormsPageState extends State<DewormsPage> {
  static const _products = ['大宠爱', '博来恩', '海乐妙'];
  final _customText = TextEditingController();
  DewormKind? _kind;
  String? _product;
  DateTime? _given;
  var _custom = false;
  var _seeded = false;
  var _busy = false;

  @override
  void dispose() {
    _customText.dispose();
    super.dispose();
  }

  void _seed(DewormRecord? last) {
    if (_seeded) return;
    _seeded = true;
    _kind = last?.kind ?? DewormKind.internal;
    final lastName = last?.product.trim() ?? '';
    if (lastName.isNotEmpty && !_products.contains(lastName)) {
      _custom = true;
      _customText.text = lastName;
      _product = lastName;
      return;
    }
    _product = lastName.isEmpty ? _products.first : lastName;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) return const NeedCatPage(title: '驱虫');
    final last = app.lastDeworm;
    _seed(last);
    final kind = _kind ?? DewormKind.internal;
    final product = _product ?? _products.first;
    final given = _given ??= dateOnly(app.now);
    final next = given.add(const Duration(days: 90));
    final items = [...app.catDeworms]
      ..sort((a, b) {
        final left = a.nextDue ?? a.givenOn;
        final right = b.nextDue ?? b.givenOn;
        return left.compareTo(right);
      });
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('驱虫'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          if (items.isEmpty)
            Text(
              '还没记驱虫',
              style: zhuaji.copyWith(color: AppColors.of(context).muted),
            )
          else
            for (final item in items.take(3)) _Record(item: item),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('体内'),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                selected: kind == DewormKind.internal,
                selectedColor: AppColors.of(context).brandTint,
                onSelected: (_) => setState(() => _kind = DewormKind.internal),
              ),
              ChoiceChip(
                label: const Text('体外'),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                selected: kind == DewormKind.external,
                selectedColor: AppColors.of(context).brandTint,
                onSelected: (_) => setState(() => _kind = DewormKind.external),
              ),
            ],
          ),
          const SizedBox(height: 8),
          KnownOrCustom(
            known: _products,
            selected: product,
            custom: _custom,
            controller: _customText,
            hint: '药名或品牌',
            onKnown: (label) => setState(() {
              _custom = false;
              _product = label;
            }),
            onCustom: () => setState(() => _custom = true),
          ),
          DateChips(
            label: '使用',
            date: given,
            today: app.now,
            onChanged: (value) => setState(() => _given = value),
          ),
          Text(
            '下次 ${formatDate(next)}',
            style: zhuaji.copyWith(color: AppColors.of(context).muted),
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
                    final name = chosenOrTyped(
                      custom: _custom,
                      controller: _customText,
                      selected: product,
                    );
                    if (name == null) {
                      showMessage(context, '先写上药名');
                      return;
                    }
                    if (dewormLoggedOn(
                      app.deworms,
                      catId: cat.id,
                      product: name,
                      day: given,
                    )) {
                      showMessage(context, '今天已经记过$name');
                      return;
                    }
                    setState(() => _busy = true);
                    await app.saveDeworm(
                      DewormDraft(
                        catId: cat.id,
                        kind: kind,
                        product: name,
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
                style: zhuaji.copyWith(
                  color: AppColors.of(context).muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            final next = await app.completeDeworm(item);
            if (!context.mounted) return;
            showUndo(
              context,
              '下次 ${formatDate(next)}',
              () => app.restoreDeworm(item),
            );
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
