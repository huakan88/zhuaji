import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../domain/parsing/gs1_parser.dart';
import '../../state/app_controller.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({required this.code, super.key});

  final String code;

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final _name = TextEditingController(text: '这袋粮');
  DateTime? _production;
  DateTime? _expiry;
  String? _batch;
  var _ready = false;
  var _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    final known = app.findBarcode(widget.code);
    if (known != null) _name.text = known.name;
    final parsed = const Gs1Parser().parse(widget.code);
    _production = parsed.productionDate;
    _expiry = parsed.suggestedExpiry;
    _batch = parsed.batch;
    _ready = true;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('确认')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '名字'),
          ),
          if (_expiry != null) ...[
            const SizedBox(height: 16),
            Text(
              '到期 ${formatDate(_expiry!)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('记下'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showMessage(context, '先写名字');
      return;
    }
    final app = AppScope.of<AppController>(context);
    setState(() => _busy = true);
    try {
      var product = app.findBarcode(widget.code);
      if (product == null || product.name != name) {
        final id = await app.saveProduct(
          FoodDraft(
            id: product?.id,
            barcode: widget.code,
            brand: product?.brand ?? '猫粮',
            name: name,
            spec: product?.spec ?? '',
            foodForm: product?.foodForm ?? FoodForm.dry,
            storageMethod: product?.storageMethod ?? '阴凉干燥',
            afterOpenDays: product?.afterOpenDays ?? 45,
            kcalPer100g: product?.kcalPer100g,
            isSample: product?.isSample ?? false,
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
          dateSource: _expiry == null && _production == null
              ? DateSource.none
              : DateSource.gs1,
        ),
      );
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
