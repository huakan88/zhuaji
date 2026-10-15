import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/food/stock.dart';
import '../../domain/food_options.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
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
            if (query.isEmpty) ...[
              const SectionLabel('先到期的排在上面'),
              const SizedBox(height: 8),
              if (stocked.isEmpty)
                EmptyHint(
                  title: '还没有',
                  body: '扫一袋就会出现在这里',
                  action: '扫码',
                  onAction: () => context.push('/scan'),
                )
              else
                for (final entry in stocked) ...[
                  _BagRow(entry: entry),
                  const SizedBox(height: 8),
                ],
            ] else if (stocked.isEmpty && catalog.isEmpty)
              EmptyHint(
                title: '没有这款',
                body: '图鉴里也没有，可以自己添加',
                action: '自己添加',
                onAction: () => context.push('/food'),
              )
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
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  '${product.brand} · 未入库',
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
                  _stockLine(entry, app.now),
                  style: zhuaji.copyWith(
                    fontSize: 12,
                    color: AppColors.of(context).muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _when(entry, app.now),
            style: zhuaji.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _stockLine(PantryEntry entry, DateTime now) {
    final estimate = estimateStock(
      spec: entry.product.spec,
      dailyGrams: entry.item.dailyGrams,
      openedAt: entry.item.openedAt,
      today: now,
    );
    if (estimate.daysLeft != null) return stockHint(estimate);
    return entry.item.openedAt == null ? '没开封' : '已开封';
  }

  String _when(PantryEntry entry, DateTime now) {
    final sooner = _sooner(entry);
    if (sooner == null) return '日期没填';
    return countdownOf(sooner, now);
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
