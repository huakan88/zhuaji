import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/food/fresh_recipes.dart';
import '../../domain/food/stock.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: zhuajiBar('自制鲜食'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _SafetyBanner(),
          const SizedBox(height: 16),
          for (final section in freshSections) ...[
            SectionLabel(section.title),
            const SizedBox(height: 8),
            for (final card in section.cards) ...[
              _RecipeTile(card: card),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({required this.cardId, super.key});

  final String cardId;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  int? _hold;
  int? _grams;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final card = freshById(widget.cardId);
    final colors = AppColors.of(context);
    if (card == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: zhuajiBar('自制鲜食'),
        body: const Center(child: Text('没有这张')),
      );
    }
    final app = AppScope.of<AppController>(context);
    final stock = card.stockId == null ? null : freshById(card.stockId!);
    final hold = _hold ?? (card.holdDays.isEmpty ? null : card.holdDays.first);
    final grams = _grams ?? (card.pickGrams ? 50 : null);
    final stored = stock == null
        ? false
        : app.findBarcode(freshBarcode(stock.id)) != null;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: zhuajiBar(card.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const _SafetyBanner(),
          const SizedBox(height: 16),
          Text(card.summary, style: zhuaji.copyWith(fontSize: 16, height: 1.4)),
          if (card.kind != FreshKind.safety &&
              card.kind != FreshKind.avoid) ...[
            const SizedBox(height: 12),
            _EnergyBlock(app: app),
          ],
          for (final paragraph in card.paragraphs) ...[
            const SizedBox(height: 12),
            Text(paragraph, style: zhuaji.copyWith(height: 1.45)),
          ],
          if (card.lines.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionLabel(card.kind == FreshKind.avoid ? '不要进碗' : '克数'),
            const SizedBox(height: 8),
            for (final line in card.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('· $line', style: zhuaji.copyWith(height: 1.4)),
              ),
          ],
          if (card.steps.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionLabel('步骤'),
            const SizedBox(height: 8),
            for (var i = 0; i < card.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${i + 1}. ${card.steps[i]}',
                  style: zhuaji.copyWith(height: 1.45),
                ),
              ),
          ],
          if (card.nutrients.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionLabel('每 1000 千卡的最低量'),
            const SizedBox(height: 8),
            for (final item in card.nutrients)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _nutrientLine(item, app),
                  style: zhuaji.copyWith(height: 1.4),
                ),
              ),
          ],
          if (card.holdDays.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionLabel(
              card.kind == FreshKind.supplement ? '提醒我过几天再看这瓶' : '冷藏提醒（不是保质期）',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final days in card.holdDays)
                  ChoiceChip(
                    label: Text('$days 天后提醒'),
                    selected: hold == days,
                    selectedColor: colors.brandTint,
                    onSelected: (_) => setState(() => _hold = days),
                  ),
              ],
            ),
          ],
          if (card.pickGrams) ...[
            const SizedBox(height: 12),
            const SectionLabel('每天从这批里喂'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final amount in dailyGramChoices)
                  ChoiceChip(
                    label: Text('$amount 克'),
                    selected: grams == amount,
                    selectedColor: colors.brandTint,
                    onSelected: (_) => setState(() => _grams = amount),
                  ),
              ],
            ),
          ],
          if (card.sources.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionLabel('来源'),
            const SizedBox(height: 8),
            for (final source in card.sources)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${source.label}\n${source.url}',
                  style: zhuaji.copyWith(
                    fontSize: 12,
                    height: 1.35,
                    color: colors.muted,
                  ),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: stock == null || hold == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _save(app, stock, hold, grams?.toDouble()),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Text(stored ? '更新提醒' : '加入粮仓并提醒'),
                ),
              ),
            ),
    );
  }

  String _nutrientLine(FreshNutrient item, AppController app) {
    final base = '${item.name}：每 1000 千卡至少 ${item.official} ${item.unit}';
    final kg = app.latestWeight?.weightKg;
    final cat = app.active;
    if (kg == null || kg <= 0 || cat == null) return base;
    final kcal = merKcal(
      kg,
      factor: cat.neutered ? neuteredAdultFactor : intactAdultFactor,
    );
    final scaled = allowancePerDay(
      per1000kcal: item.per1000kcal,
      dailyKcal: kcal,
    );
    return '$base。按 ${formatMeasure(kcal)} 千卡大约 ${formatMeasure(scaled)} ${item.unit}/天';
  }

  Future<void> _save(
    AppController app,
    FreshCard stock,
    int hold,
    double? grams,
  ) async {
    final had = app.findBarcode(freshBarcode(stock.id)) != null;
    setState(() => _busy = true);
    await app.addFreshToPantry(
      cardId: stock.id,
      holdDays: hold,
      dailyGrams: grams,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!mounted) return;
    showMessage(context, had ? '提醒更新了' : '已加入粮仓');
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tintWarning,
        borderRadius: BorderRadius.circular(Radii.l),
        border: Border.all(color: colors.warning),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '长期当主食前，先给兽医或营养师确认',
              style: zhuaji.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.warning,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '这里不是一张可以直接照做的全价食谱。洋葱、大蒜、葡萄、巧克力、生鱼不要喂。',
              style: zhuaji.copyWith(height: 1.4, color: colors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergyBlock extends StatelessWidget {
  const _EnergyBlock({required this.app});

  final AppController app;

  @override
  Widget build(BuildContext context) {
    final cat = app.active;
    final kg = app.latestWeight?.weightKg;
    final text = energySentence(cat: cat, kilograms: kg);
    return Text(text, style: zhuaji.copyWith(height: 1.45));
  }
}

String energySentence({required CatProfile? cat, required double? kilograms}) {
  if (cat == null) return '先选择一只猫，再估算每天千卡。';
  if (kilograms == null || kilograms <= 0) {
    return '${cat.name}还没有体重。先在健康里记一次，再回来看每天多少千卡。';
  }
  final factor = cat.neutered ? neuteredAdultFactor : intactAdultFactor;
  final kcal = merKcal(kilograms, factor: factor);
  final who = cat.neutered ? '绝育' : '未绝育';
  final loss = cat.goal == CareGoal.loss ? '正在减重的话，不要用这个数当目标，问兽医。' : '';
  return '${cat.name}$who，最近 ${formatMeasure(kilograms)} 千克，起步约 ${formatMeasure(kcal)} 千卡/天。实际需要可能差一半，要看体重再改。$loss';
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.card});

  final FreshCard card;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final warning =
        card.kind == FreshKind.safety || card.kind == FreshKind.avoid;
    return QuietCard(
      onTap: () => context.push('/recipe?id=${card.id}'),
      child: Row(
        children: [
          IconWell(icon: _icon(card.kind)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: zhuaji.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: warning ? colors.warning : colors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  card.summary,
                  style: zhuaji.copyWith(
                    fontSize: 12,
                    height: 1.35,
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(FreshKind kind) => switch (kind) {
    FreshKind.safety => Icons.health_and_safety_outlined,
    FreshKind.avoid => Icons.block,
    FreshKind.recipe => Icons.soup_kitchen_outlined,
    FreshKind.amount => Icons.scale_outlined,
    FreshKind.supplement => Icons.science_outlined,
  };
}
