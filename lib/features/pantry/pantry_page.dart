import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/food/recognition_draft.dart';
import '../../domain/food/stock.dart';
import '../../domain/food_options.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import 'scan_page.dart';
import '../shell/scan_button.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final bags = [...app.pantry]
      ..sort((a, b) {
        final left = _sooner(a) ?? DateTime(2100);
        final right = _sooner(b) ?? DateTime(2100);
        return left.compareTo(right);
      });
    final query = _query.text.trim();
    final stocked = query.isEmpty
        ? bags
        : [
            for (final entry in bags)
              if (foodMatchesQuery(entry.product, query)) entry,
          ];
    final stockedIds = {for (final entry in stocked) entry.product.id};
    final catalog = query.isEmpty
        ? const <FoodProduct>[]
        : [
            for (final item in filterFoods(app.products, query))
              if (!stockedIds.contains(item.id)) item,
          ];
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('粮仓'),
      body: FadeIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: '品牌、名字或条码',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                const ScanCameraButton(),
              ],
            ),
            if (app.shareQueue.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                shareQueueNotice(app.shareQueue.length),
                style: zhuaji.copyWith(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.of(context).muted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Link('拍贴纸', () => context.push('/sticker')),
                _Link('自定义猫粮', () => context.push('/food')),
                _Link('自制鲜食', () => context.push('/recipes')),
                _Link('图鉴', () => context.push('/catalog')),
              ],
            ),
            const SizedBox(height: 16),
            if (query.isEmpty && app.openDrafts.isNotEmpty) ...[
              const SectionLabel('最近识别'),
              const SizedBox(height: 8),
              for (final draft in app.openDrafts.take(3)) ...[
                _DraftRow(draft: draft),
                const SizedBox(height: 8),
              ],
            ],
            if (query.isEmpty) ...[
              const SectionLabel('先到期的排在上面'),
              const SizedBox(height: 8),
              if (stocked.isEmpty)
                EmptyHint(
                  title: '还没有粮',
                  body: '扫包装上的条码，这袋就会出现在这里',
                  action: '扫码',
                  onAction: () => context.push('/scan'),
                )
              else
                for (final entry in stocked) ...[
                  _BagRow(entry: entry),
                  const SizedBox(height: 8),
                ],
            ] else if (stocked.isEmpty && catalog.isEmpty)
              _PantryMiss(app: app, query: query)
            else ...[
              if (stocked.isNotEmpty) ...[
                const SectionLabel('粮仓'),
                const SizedBox(height: 8),
                for (final entry in stocked) ...[
                  _BagRow(entry: entry),
                  const SizedBox(height: 8),
                ],
              ],
              if (catalog.isNotEmpty) ...[
                const SectionLabel('猫粮库'),
                const SizedBox(height: 8),
                for (final item in catalog) ...[
                  _CatalogRow(product: item),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({required this.draft});

  final RecognitionDraft draft;

  @override
  Widget build(BuildContext context) {
    final hint = draft.expiry == null ? '到期日没填，接着写' : '接着填';
    return QuietCard(
      onTap: () => context.push(draft.resumeRoute),
      child: Row(
        children: [
          const IconWell(icon: Icons.history),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: zhuaji.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: zhuaji.copyWith(
                    fontSize: 12,
                    color: AppColors.of(context).muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.of(context).ink,
        minimumSize: const Size(48, 48),
      ),
      child: Text(
        label,
        style: zhuaji.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({required this.product});

  final FoodProduct product;

  @override
  Widget build(BuildContext context) {
    return QuietCard(
      onTap: () => context.push('/confirm?product=${product.id}'),
      child: Row(
        children: [
          const IconWell(icon: Icons.menu_book_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: zhuaji.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.brand} · 还没放进粮仓',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: zhuaji.copyWith(
                    fontSize: 12,
                    color: AppColors.of(context).muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BagRow extends StatelessWidget {
  const _BagRow({required this.entry});

  final PantryEntry entry;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    return QuietCard(
      onTap: () => context.push('/bag?id=${entry.item.id}'),
      child: Row(
        children: [
          const IconWell(icon: Icons.inventory_2_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: zhuaji.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _status(entry, app.now),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: zhuaji.copyWith(
                    fontSize: 12,
                    color: AppColors.of(context).muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _status(PantryEntry entry, DateTime now) {
    return bagStatus(
      estimate: estimateStock(
        spec: entry.product.spec,
        dailyGrams: entry.item.dailyGrams,
        openedAt: entry.item.openedAt,
        today: now,
      ),
      expiry: entry.item.expiryDate,
      useBy: openedUseBy(entry),
      today: now,
      opened: entry.item.openedAt != null,
    );
  }
}

class _PantryMiss extends StatelessWidget {
  const _PantryMiss({required this.app, required this.query});

  final AppController app;
  final String query;

  @override
  Widget build(BuildContext context) {
    final miss = searchMissFor(
      query,
      remembered: rememberedBarcode(app, query),
    );
    final generic = !miss.lookup && miss.title == '没有找到';
    return EmptyHint(
      title: miss.lookup || generic ? '没有这款' : miss.title,
      body: generic
          ? '图鉴里也没有。可以手写品牌、名称和规格并保存，或扫包装上的条码。'
          : miss.body,
      action: generic ? '自己添加' : miss.action,
      onAction: () {
        if (generic) {
          context.push(createFoodRoute(query));
          return;
        }
        if (!miss.lookup) {
          context.push('/scan');
          return;
        }
        _open(context);
      },
      secondary: generic ? '扫码' : '自己添加',
      onSecondary: () => context.push(
        generic ? '/scan' : createFoodRoute(query),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final route = await scanDestination(app, query);
    if (!context.mounted) return;
    context.push(route);
  }
}

DateTime? _sooner(PantryEntry entry) {
  final expiry = entry.item.expiryDate;
  final opened = entry.item.openedAt;
  DateTime? useBy;
  if (opened != null && entry.openWindowDays > 0) {
    useBy = dateOnly(opened).add(Duration(days: entry.openWindowDays));
  }
  DateTime? sooner;
  for (final date in [expiry, useBy]) {
    if (date == null) continue;
    final day = dateOnly(date);
    if (sooner == null || day.isBefore(sooner)) sooner = day;
  }
  return sooner;
}
