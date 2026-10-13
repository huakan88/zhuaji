import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../domain/parsing/gs1_parser.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({required this.code, super.key});

  final String code;

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final _name = TextEditingController();
  DateTime? _production;
  DateTime? _expiry;
  DateTime? _opened;
  var _days = 30;
  String _storage = '阴凉干燥，封好袋口。';
  String? _brand;
  String? _batch;
  var _fromCode = false;
  var _ready = false;
  var _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    final today = dateOnly(app.now);
    final known = widget.code.isEmpty ? null : app.findBarcode(widget.code);
    final parsed = const Gs1Parser().parse(widget.code);
    _fromCode = parsed.recognized;
    _production =
        parsed.productionDate ?? today.subtract(const Duration(days: 30));
    _expiry = parsed.suggestedExpiry ?? today.add(const Duration(days: 365));
    _opened = today;
    _batch = parsed.batch;
    final fallback = _fallbackProduct(app, known);
    _applyProduct(fallback, keepName: known != null);
    if (known != null) _name.text = known.name;
    _ready = true;
  }

  FoodProduct? _fallbackProduct(AppController app, FoodProduct? known) {
    if (known != null) return known;
    for (final item in app.products) {
      if (item.name.contains('室内成猫')) return item;
    }
    return app.products.isEmpty ? null : app.products.first;
  }

  void _applyProduct(FoodProduct? product, {bool keepName = false}) {
    if (product == null) {
      if (_name.text.trim().isEmpty) _name.text = '这袋粮';
      return;
    }
    _brand = product.brand;
    if (!keepName) _name.text = product.name;
    if (product.afterOpenDays > 0) _days = product.afterOpenDays;
    final line = _oneLine(product.storageMethod);
    if (line.isNotEmpty) _storage = line;
  }

  String _oneLine(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';
    final sentence = text.split('。').first.trim();
    if (sentence.isEmpty) return '';
    return sentence.endsWith('。') ? sentence : '$sentence。';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final brands = <String>[];
    final seenBrands = <String>{};
    for (final item in app.products) {
      if (item.brand.isEmpty || !seenBrands.add(item.brand)) continue;
      brands.add(item.brand);
    }
    final products = [
      for (final item in app.products)
        if (_brand != null && item.brand == _brand) item,
    ];
    final matched =
        widget.code.isNotEmpty && app.findBarcode(widget.code) != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('确认')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            _fromCode ? '日期已填上，核对后记下' : '没认到日期，用滚轮改',
            style: zhuaji.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '粮名'),
          ),
          if (!matched && brands.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('品牌', style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final brand in brands)
                  ChoiceChip(
                    label: Text(_shortBrand(brand)),
                    selected: brand == _brand,
                    selectedColor: AppColors.coral,
                    onSelected: (_) {
                      FoodProduct? first;
                      for (final item in app.products) {
                        if (item.brand == brand) {
                          first = item;
                          break;
                        }
                      }
                      setState(() {
                        _brand = brand;
                        _applyProduct(first);
                      });
                    },
                  ),
              ],
            ),
            if (products.length > 1) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in products)
                    ChoiceChip(
                      label: Text(item.name),
                      selected: item.name == _name.text,
                      selectedColor: AppColors.tintCoral,
                      onSelected: (_) => setState(() => _applyProduct(item)),
                    ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 12),
          Text(_storage, style: zhuaji.copyWith(height: 1.4)),
          const SizedBox(height: 8),
          _dateRow('生产', _production!, (value) => _production = value),
          _dateRow('到期', _expiry!, (value) => _expiry = value),
          _dateRow('开封', _opened!, (value) => _opened = value),
          const SizedBox(height: 8),
          Text('开封后', style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final days in _dayChoices)
                ChoiceChip(
                  label: Text('$days天'),
                  selected: _days == days,
                  selectedColor: AppColors.coral,
                  onSelected: (_) => setState(() => _days = days),
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

  List<int> get _dayChoices {
    final values = {7, 30, 42, _days};
    final list = values.toList()..sort();
    return list;
  }

  Widget _dateRow(
    String label,
    DateTime value,
    void Function(DateTime) assign,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(formatDate(value), style: zhuaji.copyWith(fontSize: 16)),
      trailing: Text('改', style: zhuaji.copyWith(color: AppColors.coralDeep)),
      onTap: () async {
        final picked = await pickDate(context, value);
        if (picked == null) return;
        setState(() => assign(dateOnly(picked)));
      },
    );
  }

  String _shortBrand(String brand) {
    final parts = brand.split(RegExp(r'\s+'));
    for (final part in parts) {
      if (RegExp(r'[\u4e00-\u9fff]').hasMatch(part)) return part;
    }
    return parts.first;
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showMessage(context, '先写粮名');
      return;
    }
    final app = AppScope.of<AppController>(context);
    setState(() => _busy = true);
    try {
      var product = widget.code.isEmpty ? null : app.findBarcode(widget.code);
      if (product == null || product.name != name) {
        FoodProduct? template;
        for (final item in app.products) {
          if (item.brand == _brand && item.name == name) {
            template = item;
            break;
          }
        }
        template ??= _fallbackProduct(app, product);
        final id = await app.saveProduct(
          FoodDraft(
            id: product?.id,
            barcode: widget.code.isEmpty ? null : widget.code,
            brand: _brand ?? template?.brand ?? '猫粮',
            name: name,
            spec: template?.spec ?? '',
            foodForm: template?.foodForm ?? FoodForm.dry,
            storageMethod: _storage,
            afterOpenDays: _days,
            kcalPer100g: template?.kcalPer100g,
            isSample: false,
          ),
        );
        product = app.productById(id);
      }
      if (product == null) return;
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
