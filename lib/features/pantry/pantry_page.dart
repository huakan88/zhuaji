import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy.dart';
import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  var _catalog = false;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final products = app.products.where((product) {
      final text = '${product.brand}${product.name}${product.barcode ?? ''}'.toLowerCase();
      return _query.isEmpty || text.contains(_query.toLowerCase());
    }).toList();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '粮仓',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => context.push('/scan'),
                  child: const Text('扫条码'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(kSampleFoodNote, style: TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: Space.x4),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('在库')),
                ButtonSegment(value: true, label: Text('图鉴')),
              ],
              selected: {_catalog},
              onSelectionChanged: (value) => setState(() => _catalog = value.first),
            ),
            const SizedBox(height: Space.x4),
            if (_catalog) ...[
              TextField(
                decoration: const InputDecoration(
                  hintText: '搜品牌、名称或示例条码',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: Space.x3),
              if (products.isEmpty)
                const EmptyHint(
                  title: '没有这款',
                  body: '换个词，或者扫一条新条码自己补上。',
                ),
              for (final product in products)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SoftCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product.displayName),
                      subtitle: Text('${formLabel(product.foodForm)} · ${product.spec}'),
                      trailing: product.isSample
                          ? const TagChip(label: '示例')
                          : const Icon(Icons.chevron_right),
                      onTap: () => context.push('/product?productId=${product.id}'),
                    ),
                  ),
                ),
            ] else if (app.pantry.isEmpty)
              const EmptyHint(
                title: '还没有在库的一袋粮',
                body: '扫条码，或从示例图鉴里点开一款，登记生产日期和保质期。',
              )
            else
              for (final entry in app.pantry)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: InkWell(
                      onTap: () => context.push(
                        '/product?productId=${entry.product.id}&pantryId=${entry.item.id}',
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.product.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (entry.item.expiryDate != null)
                                TagChip(
                                  label: countdownOf(entry.item.expiryDate!, app.now),
                                  tint: AppColors.tintCoral,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${formLabel(entry.product.foodForm)} · ${entry.product.spec}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.item.openedAt == null
                                ? '未开封 · ${entry.product.storageMethod}'
                                : '已开封 · 建议 ${entry.openWindowDays} 天内喂完',
                            style: const TextStyle(fontSize: 12, height: 1.35),
                          ),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '查看并修改日期',
                              style: TextStyle(color: AppColors.olive, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
