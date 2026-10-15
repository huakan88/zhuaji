import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../domain/parsing/gs1_parser.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({
    required this.code,
    this.productId,
    this.blank = false,
    super.key,
  });

  final String code;

  /// Set when the person picked this food from search instead of a scan.
  final int? productId;

  /// A retail code the public databases did not know. Do not invent a product.
  final bool blank;

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  FoodProduct? _product;
  DateTime? _production;
  DateTime? _expiry;
  DateTime? _opened;
  var _days = 30;
  String _storage = '阴凉干燥，封好袋口。';
  String? _batch;
  var _fromCode = false;
  var _rechoose = false;
  var _ready = false;
  var _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    final today = dateOnly(app.now);
    final known = widget.code.isEmpty ? null : app.findBarcode(widget.code);
    final pinned = widget.productId == null
        ? null
        : app.productById(widget.productId!);
    final parsed = const Gs1Parser().parse(widget.code);
    _fromCode = parsed.recognized;
    _production =
        parsed.productionDate ?? today.subtract(const Duration(days: 30));
    _expiry = parsed.suggestedExpiry ?? today.add(const Duration(days: 365));
    _opened = today;
    _batch = parsed.batch;
    if (widget.blank && pinned == null && known == null) {
      _product = null;
    } else {
      _apply(pinned ?? known ?? _fallback(app));
    }
    _ready = true;
  }

  FoodProduct? _fallback(AppController app) {
    for (final item in app.products) {
      if (item.name.contains('室内成猫')) return item;
    }
    return app.products.isEmpty ? null : app.products.first;
  }

  void _apply(FoodProduct? product) {
    _product = product;
    if (product == null) return;
    if (product.afterOpenDays > 0) _days = product.afterOpenDays;
    final line = _oneLine(product.storageMethod);
    if (line.isNotEmpty) _storage = line;
  }

  String _oneLine(String raw) {
    final sentence = raw.trim().split('。').first.trim();
    if (sentence.isEmpty) return '';
    return sentence.endsWith('。') ? sentence : '$sentence。';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final brands = <String>[];
    final seen = <String>{};
    for (final item in app.products) {
      if (item.brand.isEmpty || !seen.add(item.brand)) continue;
      brands.add(item.brand);
    }
    final selectedBrand = _product?.brand;
    if (selectedBrand != null && brands.remove(selectedBrand)) {
      brands.insert(0, selectedBrand);
    }
    final products = [
      for (final item in app.products)
        if (_product != null && item.brand == _product!.brand) item,
    ];
    final known = widget.code.isEmpty ? null : app.findBarcode(widget.code);
    final matched = known != null && !_rechoose;
    final fromSearch = widget.productId != null && !_rechoose && !matched;
    final locked = matched || fromSearch;
    final days = {7, 30, 42, _days}.toList()..sort();
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('确认'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          Text(
            _product?.name ?? '先选品牌',
            style: zhuaji.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            _fromCode
                ? '日期已填上，核对后记下'
                : matched
                ? '日期用滚轮改'
                : '点品牌，日期用滚轮改',
            style: zhuaji.copyWith(
              fontSize: 13,
              color: AppColors.of(context).muted,
            ),
          ),
          if (matched)
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.of(context).brandDeep,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '认得这个码',
                    style: zhuaji.copyWith(
                      fontSize: 13,
                      color: AppColors.of(context).brandDeep,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _rechoose = true),
                  child: const Text('不是这个'),
                ),
              ],
            )
          else if (widget.code.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '选好品牌记下后，下次扫这个码直接认出',
                style: zhuaji.copyWith(
                  fontSize: 13,
                  color: AppColors.of(context).muted,
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final code = widget.code.trim();
              final query = code.isEmpty
                  ? ''
                  : '?code=${Uri.encodeComponent(code)}';
              final id = await context.push<int>('/food$query');
              if (id == null || !context.mounted) return;
              final chosen = AppScope.of<AppController>(context)
                  .productById(id);
              setState(() {
                _rechoose = false;
                _apply(chosen);
              });
            },
            child: const Text('自己添加'),
          ),
          if (!locked && brands.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionLabel('品牌'),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final brand in brands)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_shortBrand(brand)),
                        selected: brand == _product?.brand,
                        selectedColor: AppColors.of(context).brandTint,
                        onSelected: (_) {
                          FoodProduct? first;
                          for (final item in app.products) {
                            if (item.brand == brand) {
                              first = item;
                              break;
                            }
                          }
                          setState(() => _apply(first));
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (products.length > 1)
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final item in products)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(item.name),
                          selected: item.id == _product?.id,
                          selectedColor: AppColors.of(context).brandTint,
                          onSelected: (_) => setState(() => _apply(item)),
                        ),
                      ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            _storage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: zhuaji.copyWith(
              fontSize: 13,
              height: 1.35,
              color: AppColors.of(context).muted,
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('日期'),
          const SizedBox(height: 8),
          QuietCard(
            child: Column(
              children: [
                DateLine(
                  label: '生产',
                  date: _production!,
                  onTap: () =>
                      _pick(_production!, (value) => _production = value),
                ),
                DateLine(
                  label: '到期',
                  date: _expiry!,
                  onTap: () => _pick(_expiry!, (value) => _expiry = value),
                ),
                DateLine(
                  label: '开封',
                  date: _opened!,
                  onTap: () => _pick(_opened!, (value) => _opened = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('开封后'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final day in days)
                ChoiceChip(
                  label: Text('$day天'),
                  selected: _days == day,
                  selectedColor: AppColors.of(context).brandTint,
                  onSelected: (_) => setState(() => _days = day),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('记下'),
          ),
        ),
      ),
    );
  }

  Future<void> _pick(DateTime current, void Function(DateTime) assign) async {
    final picked = await pickDate(context, current);
    if (picked == null) return;
    setState(() => assign(dateOnly(picked)));
  }

  String _shortBrand(String brand) {
    final parts = brand.split(RegExp(r'\s+'));
    for (final part in parts) {
      if (RegExp(r'[\u4e00-\u9fff]').hasMatch(part)) return part;
    }
    return parts.first;
  }

  Future<void> _save() async {
    final product = _product;
    if (product == null) {
      showMessage(context, '先选品牌');
      return;
    }
    final app = AppScope.of<AppController>(context);
    setState(() => _busy = true);
    try {
      final code = widget.code.trim();
      if (code.isNotEmpty && app.findBarcode(code)?.id != product.id) {
        await app.rememberBarcode(code, product.id);
      }
      await app.savePantry(
        PantryDraft(
          productId: product.id,
          productionDate: _production,
          expiryDate: _expiry,
          batch: _batch,
          dateSource: _fromCode ? DateSource.gs1 : DateSource.manual,
          openedAt: _opened,
          afterOpenDays: _days,
        ),
      );
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
