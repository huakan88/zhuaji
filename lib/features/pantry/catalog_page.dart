import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/food_options.dart';
import '../../state/app_controller.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final foods = filterFoods(app.products, _query.text);
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('图鉴'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(labelText: '搜索'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            '自己加的猫粮也在这里',
            style: zhuaji.copyWith(
              fontSize: 12,
              color: AppColors.of(context).muted,
            ),
          ),
          const SizedBox(height: 12),
          if (foods.isEmpty)
            EmptyHint(
              title: '没有这款',
              body: '拍包装正面，品牌和名称会自动填上',
              action: '自己添加',
              onAction: () => context.push('/food'),
            )
          else
            for (final item in foods) ...[
              QuietCard(
                onTap: item.isCustom
                    ? () => context.push('/food?id=${item.id}')
                    : null,
                child: Row(
                  children: [
                    const IconWell(icon: Icons.restaurant_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: zhuaji.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              formLabel(item.foodForm),
                              if (item.flavor.isNotEmpty) item.flavor,
                              if (item.spec.isNotEmpty) item.spec,
                              if (item.isCustom) '自定义',
                            ].join(' · '),
                            style: zhuaji.copyWith(
                              fontSize: 12,
                              color: AppColors.of(context).muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.isCustom)
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.of(context).muted,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: () => context.push('/food'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('自己添加'),
          ),
        ),
      ),
    );
  }
}
