import 'package:flutter/material.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/food/barcode_lookup.dart';
import '../../domain/food/local_barcodes.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

/// Brand, name and spec live on the product. Ingredients and nutrients
/// live on the saved lookup, or on the built-in list when the cache is empty.
BarcodeRecord? shelfRecord(AppController app, FoodProduct product) {
  final code = product.barcode?.trim() ?? '';
  if (code.isEmpty) return null;
  final cached = app.cachedBarcode(code);
  final local = localCatFood(code)?.toRecord();
  if (cached == null) return local;
  if (local == null) return cached;
  final ingredients = cached.ingredients.trim().isNotEmpty
      ? cached.ingredients
      : local.ingredients;
  final nutrients = cached.nutrients.isNotEmpty
      ? cached.nutrients
      : local.nutrients;
  if (ingredients == cached.ingredients &&
      identical(nutrients, cached.nutrients)) {
    return cached;
  }
  return BarcodeRecord(
    code: cached.code,
    found: cached.found,
    brand: cached.brand,
    name: cached.name,
    quantity: cached.quantity,
    ingredients: ingredients,
    nutrients: nutrients,
    source: cached.source,
    imageUrl: cached.imageUrl,
    sourceUrl: cached.sourceUrl,
    kcalPer100g: cached.kcalPer100g,
    offline: cached.offline,
    incomplete: cached.incomplete,
    createdAt: cached.createdAt,
    updatedAt: cached.updatedAt,
    contributorId: cached.contributorId,
  );
}

/// Spec, ingredients and nutrients on the page a scan already opened.
class ProductFacts extends StatelessWidget {
  const ProductFacts({required this.product, this.record, super.key});

  final FoodProduct product;
  final BarcodeRecord? record;

  @override
  Widget build(BuildContext context) {
    final spec = product.spec.trim().isNotEmpty
        ? product.spec.trim()
        : (record?.quantity.trim() ?? '');
    final ingredients = record?.ingredients.trim() ?? '';
    final nutrients = record?.nutrients ?? const <BarcodeNutrient>[];
    if (spec.isEmpty && ingredients.isEmpty && nutrients.isEmpty) {
      return const SizedBox.shrink();
    }
    final muted = zhuaji.copyWith(
      fontSize: 12,
      color: AppColors.of(context).muted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (spec.isNotEmpty) ...[
          Text('规格', style: muted),
          const SizedBox(height: 2),
          Text(spec, style: zhuaji.copyWith(fontSize: 16)),
        ],
        if (ingredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          const SectionLabel('配料'),
          const SizedBox(height: 8),
          Text(ingredients, style: zhuaji.copyWith(fontSize: 14, height: 1.45)),
        ],
        if (nutrients.isNotEmpty) ...[
          const SizedBox(height: 12),
          const SectionLabel('成分'),
          const SizedBox(height: 8),
          for (final item in nutrients)
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
      ],
    );
  }
}
