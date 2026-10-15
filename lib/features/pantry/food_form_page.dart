import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/food_options.dart';
import '../../domain/models.dart';
import '../../domain/parsing/pack_front_parser.dart';
import '../../services/date_ocr_service.dart';
import '../../services/pack_ocr_service.dart';
import '../../services/photo_store.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class FoodFormPage extends StatefulWidget {
  const FoodFormPage({
    this.productId,
    this.barcode = '',
    this.openCamera = false,
    this.addBag = false,
    super.key,
  });

  final int? productId;
  final String barcode;
  final bool openCamera;

  /// True when this bag should also land in the pantry. Catalog edits do not.
  final bool addBag;

  @override
  State<FoodFormPage> createState() => _FoodFormPageState();
}

class _FoodFormPageState extends State<FoodFormPage> {
  final _brand = TextEditingController();
  final _name = TextEditingController();
  final _photos = PhotoStore();
  String? _photo;
  String _flavor = '';
  var _form = FoodForm.dry;
  String _spec = '';
  DateTime? _expiry;
  var _dateFromPhoto = false;
  var _ready = false;
  var _busy = false;
  var _askedCamera = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    final existing = widget.productId == null
        ? null
        : app.productById(widget.productId!);
    if (existing != null && existing.isCustom) {
      _brand.text = existing.brand;
      _name.text = existing.name;
      _flavor = existing.flavor;
      _form = existing.foodForm;
      _spec = existing.spec;
      _photo = existing.photoPath;
    }
    if (widget.addBag && widget.productId == null) {
      _expiry = dateOnly(app.now).add(const Duration(days: 365));
    }
    _ready = true;
    if (widget.openCamera && !_askedCamera) {
      _askedCamera = true;
      if (Platform.environment['FLUTTER_TEST'] != 'true') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _readPack(ImageSource.camera);
        });
      }
    }
  }

  @override
  void dispose() {
    _brand.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.productId != null;
    final specs = [...foodSpecs];
    if (_spec.isNotEmpty && !specs.contains(_spec)) specs.insert(0, _spec);
    final flavors = foodFlavors.where((item) => item != '鱼').toList();
    if (_flavor.isNotEmpty && !flavors.contains(_flavor)) {
      flavors.insert(0, _flavor);
    }
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar(editing ? '改这款' : '自己添加'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          if (_photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.l),
              child: Image.file(
                File(_photo!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _readPack(ImageSource.camera),
                  child: const Text('拍包装正面'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _readPack(ImageSource.gallery),
                  child: const Text('相册'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '拍完会填上品牌和名称，核对一下就行',
            style: zhuaji.copyWith(
              fontSize: 12,
              color: AppColors.of(context).muted,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _brand,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: '品牌'),
          ),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: '名称'),
          ),
          const SizedBox(height: 16),
          const SectionLabel('形态'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final form in FoodForm.values)
                ChoiceChip(
                  label: Text(formLabel(form)),
                  selected: _form == form,
                  selectedColor: AppColors.of(context).brandTint,
                  onSelected: (_) => setState(() => _form = form),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('口味'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final flavor in flavors)
                ChoiceChip(
                  label: Text(flavor),
                  selected: _flavor == flavor,
                  selectedColor: AppColors.of(context).brandTint,
                  onSelected: (_) => setState(() {
                    _flavor = _flavor == flavor ? '' : flavor;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('规格'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final spec in specs)
                ChoiceChip(
                  label: Text(spec),
                  selected: _spec == spec,
                  selectedColor: AppColors.of(context).brandTint,
                  onSelected: (_) => setState(() {
                    _spec = _spec == spec ? '' : spec;
                  }),
                ),
            ],
          ),
          if (_expiry != null) ...[
            const SizedBox(height: 16),
            const SectionLabel('这袋的保质期'),
            const SizedBox(height: 8),
            QuietCard(
              child: DateLine(
                label: '到期',
                date: _expiry!,
                onTap: () async {
                  final picked = await pickDate(context, _expiry!);
                  if (picked == null) return;
                  setState(() {
                    _expiry = dateOnly(picked);
                    _dateFromPhoto = false;
                  });
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _busy ? null : _readExpiry,
                child: const Text('拍保质期'),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('保存'),
              ),
              if (editing)
                TextButton(
                  onPressed: _busy ? null : _delete,
                  child: const Text('删除'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _readPack(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _busy = true);
      final brands = [
        for (final item in AppScope.of<AppController>(context).products)
          item.brand,
      ];
      final stored = await _photos.persist(file.path, frameSubject: false);
      if (!mounted) return;
      final read = await const PackOcrService().readFile(
        stored,
        extraBrands: brands,
      );
      if (!mounted) return;
      _applyRead(stored, read);
    } catch (_) {
      if (!mounted) return;
      showMessage(context, '没打开相机');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _applyRead(String path, PackRead read) {
    setState(() {
      _photo = path;
      if (read.brand != null && read.brand!.isNotEmpty) {
        _brand.text = read.brand!;
      }
      if (read.name != null && read.name!.isNotEmpty) _name.text = read.name!;
      if (read.flavor != null) _flavor = read.flavor!;
      if (read.form != null) _form = read.form!;
      if (read.spec != null) _spec = read.spec!;
    });
    showMessage(
      context,
      read.brand == null && read.name == null ? '没认出字，补一下品牌' : '认出来了，核对一下',
    );
  }

  Future<void> _readExpiry() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _busy = true);
      final stored = await _photos.persist(file.path, frameSubject: false);
      final result = await const DateOcrService().readFile(stored);
      if (!mounted) return;
      final expiry = result.expiryDate;
      if (expiry == null) {
        showMessage(context, '没认出日期，用滚轮选');
        return;
      }
      setState(() {
        _expiry = dateOnly(expiry);
        _dateFromPhoto = true;
      });
      showMessage(context, '日期填上了，核对一下');
    } catch (_) {
      if (!mounted) return;
      showMessage(context, '没打开相机');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final brand = _brand.text.trim();
    final name = _name.text.trim();
    if (brand.isEmpty || name.isEmpty) {
      showMessage(context, '先确认品牌和名称');
      return;
    }
    final app = AppScope.of<AppController>(context);
    final code = widget.barcode.trim();
    if (_barcodeTaken(app, code, widget.productId)) {
      showMessage(context, '这个条码已经绑在别的猫粮上');
      return;
    }
    setState(() => _busy = true);
    try {
      final existing = widget.productId == null
          ? null
          : app.productById(widget.productId!);
      final id = await app.saveFood(
        FoodDraft(
          id: widget.productId,
          barcode: existing?.barcode,
          brand: brand,
          name: name,
          spec: _spec,
          foodForm: _form,
          storageMethod: existing?.storageMethod ?? _storage(_form),
          afterOpenDays: existing?.afterOpenDays ?? _days(_form),
          flavor: _flavor,
          isCustom: true,
          photoPath: _photo,
        ),
        barcode: code.isEmpty ? existing?.barcode : code,
      );
      if (widget.addBag && widget.productId == null && _expiry != null) {
        await app.savePantry(
          PantryDraft(
            productId: id,
            expiryDate: _expiry,
            dateSource: _dateFromPhoto ? DateSource.ocr : DateSource.manual,
            afterOpenDays: _days(_form),
          ),
        );
      }
      if (!mounted) return;
      context.pop(id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final id = widget.productId;
    if (id == null) return;
    final app = AppScope.of<AppController>(context);
    final bags = app.pantryCountOf(id);
    final title = bags > 0 ? '删除这款？粮仓里的 $bags 袋会一起去掉' : '删除这款？';
    if (!await confirmDelete(context, title)) return;
    if (!mounted) return;
    setState(() => _busy = true);
    await app.deleteFood(id);
    if (!mounted) return;
    context.pop();
  }
}

bool _barcodeTaken(AppController app, String code, int? exceptId) {
  final key = barcodeKey(code);
  if (key.isEmpty) return false;
  for (final item in app.products) {
    final own = item.barcode;
    if (item.id == exceptId || own == null || own.isEmpty) continue;
    if (barcodeKey(own) == key) return true;
  }
  return false;
}

String _storage(FoodForm form) => switch (form) {
  FoodForm.wet || FoodForm.can => '开封后冷藏，尽快喂完。',
  _ => '阴凉干燥，封好袋口。',
};

int _days(FoodForm form) => switch (form) {
  FoodForm.wet || FoodForm.can => 2,
  _ => 30,
};
