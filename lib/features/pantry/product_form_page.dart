import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({this.barcode, super.key});

  final String? barcode;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final TextEditingController _brand = TextEditingController();
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _spec = TextEditingController(text: '示例规格，请改成包装上的');
  late final TextEditingController _kcal = TextEditingController();
  late final TextEditingController _storage = TextEditingController(
    text: '阴凉干燥处密封保存',
  );
  late final TextEditingController _days = TextEditingController(text: '42');
  FoodForm _form = FoodForm.dry;

  @override
  void dispose() {
    _brand.dispose();
    _name.dispose();
    _spec.dispose();
    _kcal.dispose();
    _storage.dispose();
    _days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加猫粮')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            widget.barcode == null
                ? '图鉴里没有这款，可以自己补一条。'
                : '没有找到条码 ${widget.barcode}。补上之后就能登记这袋粮。',
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(controller: _brand, decoration: const InputDecoration(labelText: '品牌')),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: const InputDecoration(labelText: '名称')),
          const SizedBox(height: 12),
          TextField(controller: _spec, decoration: const InputDecoration(labelText: '规格')),
          const SizedBox(height: 12),
          DropdownButtonFormField<FoodForm>(
            initialValue: _form,
            decoration: const InputDecoration(labelText: '形态'),
            items: [
              for (final form in FoodForm.values)
                DropdownMenuItem(value: form, child: Text(formLabel(form))),
            ],
            onChanged: (value) => setState(() {
              _form = value ?? _form;
              if (_form == FoodForm.wet) {
                _days.text = '2';
                _storage.text = '未开封阴凉保存。开封后冷藏并尽快喂完。';
              }
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _kcal,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '每 100g 热量（可选，kcal）'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _storage,
            maxLines: 2,
            decoration: const InputDecoration(labelText: '储存方式'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _days,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: '开封后建议天数'),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('保存并登记')),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_brand.text.trim().isEmpty || _name.text.trim().isEmpty) {
      showMessage(context, '品牌和名称都要填');
      return;
    }
    final days = int.tryParse(_days.text) ?? 42;
    final app = AppScope.of<AppController>(context);
    final id = await app.saveProduct(
      FoodDraft(
        barcode: widget.barcode,
        brand: _brand.text,
        name: _name.text,
        spec: _spec.text,
        foodForm: _form,
        kcalPer100g: double.tryParse(_kcal.text),
        storageMethod: _storage.text,
        afterOpenDays: days,
      ),
    );
    if (!mounted) return;
    context.pushReplacement('/product?productId=$id');
  }
}
