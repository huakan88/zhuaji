import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/food/recognition_draft.dart';
import '../../domain/food_options.dart';
import '../../domain/models.dart';
import '../../domain/parsing/pack_front_parser.dart';
import '../../services/date_ocr_service.dart';
import '../../services/pack_ocr_service.dart';
import '../../services/photo_store.dart';
import '../../state/app_controller.dart';
import '../health/known_or_custom.dart';
import '../records/record_sheets.dart';

class FoodFormPage extends StatefulWidget {
  const FoodFormPage({
    this.productId,
    this.barcode = '',
    this.initialName = '',
    this.draftId,
    this.openCamera = false,
    this.addBag = false,
    super.key,
  });

  final int? productId;
  final String barcode;
  final String initialName;
  final String? draftId;
  final bool openCamera;

  /// True when this bag should also land in the pantry. Catalog edits do not.
  final bool addBag;

  @override
  State<FoodFormPage> createState() => _FoodFormPageState();
}

class _FoodFormPageState extends State<FoodFormPage> {
  final _brand = TextEditingController();
  final _name = TextEditingController();
  final _flavorText = TextEditingController();
  final _specText = TextEditingController();
  final _formText = TextEditingController();
  final _ingredients = TextEditingController();
  final _photos = PhotoStore();
  String? _photo;
  String _flavor = '';
  var _flavorCustom = false;
  var _form = FoodForm.dry;
  var _formCustom = false;
  String _spec = '';
  var _specCustom = false;
  DateTime? _production;
  DateTime? _expiry;
  var _dateFromPhoto = false;
  int? _productId;
  int? _pantryId;
  var _ready = false;
  var _busy = false;
  var _askedCamera = false;
  var _silent = false;
  Future<void> _draftTail = Future<void>.value();

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _brand,
      _name,
      _flavorText,
      _specText,
      _formText,
      _ingredients,
    ]) {
      controller.addListener(_onField);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    final draft = app.draftFor(id: widget.draftId, barcode: widget.barcode);
    final existingId = widget.productId ?? draft?.productId;
    final existing = existingId == null ? null : app.productById(existingId);
    _productId = existing?.id ?? draft?.productId;
    _pantryId = draft?.pantryId;
    if (existing != null && existing.isCustom) {
      _brand.text = existing.brand;
      _name.text = existing.name;
      _flavor = existing.flavor;
      if (existing.flavor.isNotEmpty && !_knownFlavor(existing.flavor)) {
        _flavorCustom = true;
        _flavorText.text = existing.flavor;
      }
      final typedForm = existing.customForm?.trim() ?? '';
      if (typedForm.isNotEmpty) {
        _formCustom = true;
        _formText.text = typedForm;
      }
      _form = existing.foodForm;
      _spec = existing.spec;
      if (existing.spec.isNotEmpty && !_knownSpec(existing.spec)) {
        _specCustom = true;
        _specText.text = existing.spec;
      }
      _photo = existing.photoPath;
    }
    if (draft != null && (existing == null || existing.isCustom)) {
      _silent = true;
      if (draft.brand.isNotEmpty) _brand.text = draft.brand;
      if (draft.name.isNotEmpty) _name.text = draft.name;
      if (draft.spec.isNotEmpty && _specText.text.isEmpty && _spec.isEmpty) {
        if (_knownSpec(draft.spec)) {
          _spec = draft.spec;
        } else {
          _specCustom = true;
          _specText.text = draft.spec;
          _spec = draft.spec;
        }
      }
      if (draft.flavor.isNotEmpty && _flavor.isEmpty) {
        if (_knownFlavor(draft.flavor)) {
          _flavor = draft.flavor;
        } else {
          _flavorCustom = true;
          _flavorText.text = draft.flavor;
          _flavor = draft.flavor;
        }
      }
      if (draft.ingredients.isNotEmpty) _ingredients.text = draft.ingredients;
      if (draft.photoPath != null && draft.photoPath!.isNotEmpty) {
        _photo = draft.photoPath;
      }
      _production = draft.production;
      _expiry = draft.expiry;
      _dateFromPhoto = draft.expiryFromOcr && draft.expiry != null;
      if (draft.formKey.isNotEmpty) _form = formFromDraft(draft);
      if (draft.customForm.isNotEmpty) {
        _formCustom = true;
        _formText.text = draft.customForm;
      }
      _silent = false;
    } else if (widget.initialName.isNotEmpty && _name.text.isEmpty) {
      _silent = true;
      _name.text = widget.initialName;
      _silent = false;
    }
    final facts = _productId == null
        ? null
        : app.draftById('facts:$_productId');
    if (facts != null && _ingredients.text.isEmpty) {
      _silent = true;
      _ingredients.text = facts.ingredients;
      _silent = false;
    }
    _ready = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.barcode.trim().isEmpty &&
          _brand.text.trim().isEmpty &&
          _name.text.trim().isEmpty) {
        return;
      }
      _captureDraft();
    });
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
    _flavorText.dispose();
    _specText.dispose();
    _formText.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  void _onField() {
    if (_silent || !_ready) return;
    _captureDraft();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.productId != null;
    final flavors = foodFlavors.where((item) => item != '鱼').toList();
    final showDates = widget.addBag || _photo != null || _expiry != null;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result == null) _captureDraft();
      },
      child: Scaffold(
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
                    onPressed: _busy ? null : () => _openPack(camera: true),
                    child: const Text('拍包装正面'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _openPack(camera: false),
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
            if (widget.barcode.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '条码 ${widget.barcode.trim()}',
                style: zhuaji.copyWith(
                  fontSize: 13,
                  color: AppColors.of(context).muted,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _ingredients,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '配料'),
            ),
            const SizedBox(height: 16),
            const SectionLabel('形态'),
            const SizedBox(height: 8),
            KnownOrCustom(
              known: [for (final form in FoodForm.values) formLabel(form)],
              selected: formLabel(_form),
              custom: _formCustom,
              controller: _formText,
              hint: '形态',
              onKnown: (label) => setState(() {
                _formCustom = false;
                _form = _formForLabel(label);
              }),
              onCustom: () => setState(() => _formCustom = true),
            ),
            const SizedBox(height: 16),
            const SectionLabel('口味'),
            const SizedBox(height: 8),
            KnownOrCustom(
              known: flavors,
              selected: _flavor,
              custom: _flavorCustom,
              controller: _flavorText,
              hint: '口味',
              onKnown: (label) => setState(() {
                if (!_flavorCustom && _flavor == label) {
                  _flavor = '';
                } else {
                  _flavorCustom = false;
                  _flavor = label;
                }
              }),
              onCustom: () => setState(() => _flavorCustom = true),
            ),
            const SizedBox(height: 16),
            const SectionLabel('规格'),
            const SizedBox(height: 8),
            KnownOrCustom(
              known: foodSpecs,
              selected: _spec,
              custom: _specCustom,
              controller: _specText,
              hint: '规格',
              onKnown: (label) => setState(() {
                if (!_specCustom && _spec == label) {
                  _spec = '';
                } else {
                  _specCustom = false;
                  _spec = label;
                }
              }),
              onCustom: () => setState(() => _specCustom = true),
            ),
            if (showDates) ...[
              const SizedBox(height: 16),
              const SectionLabel('这袋的日期'),
              const SizedBox(height: 8),
              Text(
                _expiry == null ? '没认出到期日，请手写。不会自动记成一年后。' : '核对一下到期日',
                style: zhuaji.copyWith(
                  fontSize: 12,
                  color: AppColors.of(context).muted,
                ),
              ),
              const SizedBox(height: 8),
              QuietCard(
                child: Column(
                  children: [
                    DateLine(
                      label: '生产',
                      date: _production,
                      placeholder: '请手写',
                      onTap: () async {
                        final picked = await pickDate(
                          context,
                          _production ??
                              dateOnly(AppScope.of<AppController>(context).now),
                        );
                        if (picked == null) return;
                        setState(() => _production = dateOnly(picked));
                        _captureDraft();
                      },
                    ),
                    DateLine(
                      label: '到期',
                      date: _expiry,
                      placeholder: '请手写',
                      onTap: () async {
                        final picked = await pickDate(
                          context,
                          _expiry ??
                              dateOnly(AppScope.of<AppController>(context).now),
                        );
                        if (picked == null) return;
                        setState(() {
                          _expiry = dateOnly(picked);
                          _dateFromPhoto = false;
                        });
                        _captureDraft();
                      },
                    ),
                  ],
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
    _silent = true;
    setState(() {
      _photo = path;
      if (read.brand != null && read.brand!.isNotEmpty) {
        _brand.text = read.brand!;
      }
      if (read.name != null && read.name!.isNotEmpty) _name.text = read.name!;
      if (read.ingredients != null && read.ingredients!.isNotEmpty) {
        _ingredients.text = read.ingredients!;
      }
      if (read.productionDate != null) {
        _production = dateOnly(read.productionDate!);
      }
      if (read.expiryDate != null) {
        _expiry = dateOnly(read.expiryDate!);
        _dateFromPhoto = true;
      } else {
        _dateFromPhoto = false;
      }
      if (read.flavor != null) {
        final flavor = read.flavor!;
        if (_knownFlavor(flavor)) {
          _flavorCustom = false;
          _flavor = flavor;
        } else {
          _flavorCustom = true;
          _flavorText.text = flavor;
          _flavor = flavor;
        }
      }
      if (read.form != null) {
        _formCustom = false;
        _form = read.form!;
      }
      if (read.spec != null) {
        final spec = read.spec!;
        if (_knownSpec(spec)) {
          _specCustom = false;
          _spec = spec;
        } else {
          _specCustom = true;
          _specText.text = spec;
          _spec = spec;
        }
      }
    });
    _silent = false;
    final missedExpiry = read.expiryDate == null;
    final missedName =
        (read.brand == null || read.brand!.isEmpty) &&
        (read.name == null || read.name!.isEmpty);
    final message = missedName && missedExpiry
        ? '没认出字。品牌、名称和到期日都可以手写。'
        : missedExpiry
        ? (read.expiryUncertain ? '日期看不清，请手写到期日' : '没认出到期日，请手写')
        : '认出来了，核对一下';
    showMessage(context, message);
    _captureDraft();
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
        showMessage(context, result.uncertain ? '日期看不清，请手写到期日' : '没认出到期日，请手写');
        _captureDraft();
        return;
      }
      setState(() {
        _expiry = dateOnly(expiry);
        if (result.productionDate != null) {
          _production = dateOnly(result.productionDate!);
        }
        _dateFromPhoto = true;
      });
      showMessage(context, '日期填上了，核对一下');
      _captureDraft();
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
    final flavor = _flavorCustom ? _flavorText.text.trim() : _flavor;
    if (_flavorCustom && flavor.isEmpty) {
      showMessage(context, '先写上口味');
      return;
    }
    final spec = _specCustom ? _specText.text.trim() : _spec;
    if (_specCustom && spec.isEmpty) {
      showMessage(context, '先写上规格');
      return;
    }
    final typedForm = _formText.text.trim();
    if (_formCustom && typedForm.isEmpty) {
      showMessage(context, '先写上形态');
      return;
    }
    final app = AppScope.of<AppController>(context);
    final code = widget.barcode.trim();
    final editingId = _productId ?? widget.productId;
    if (_barcodeTaken(app, code, editingId)) {
      showMessage(context, '这个条码已经绑在别的猫粮上');
      return;
    }
    setState(() => _busy = true);
    try {
      final existing = editingId == null ? null : app.productById(editingId);
      final id = await app.saveFood(
        FoodDraft(
          id: editingId,
          barcode: existing?.barcode,
          brand: brand,
          name: name,
          spec: spec,
          foodForm: _form,
          customForm: _formCustom ? typedForm : null,
          storageMethod: existing?.storageMethod ?? _storage(_form),
          afterOpenDays: existing?.afterOpenDays ?? _days(_form),
          flavor: flavor,
          isCustom: true,
          photoPath: _photo,
        ),
        barcode: code.isEmpty ? existing?.barcode : code,
      );
      _productId = id;
      if (widget.addBag && widget.productId == null) {
        _pantryId = await app.savePantry(
          PantryDraft(
            id: _pantryId,
            productId: id,
            productionDate: _production,
            expiryDate: _expiry,
            dateSource: _expiry == null
                ? DateSource.none
                : (_dateFromPhoto ? DateSource.ocr : DateSource.manual),
            afterOpenDays: _days(_form),
          ),
        );
      }
      final saved = app.productById(id);
      final savedCode = code.isEmpty ? (existing?.barcode ?? '') : code;
      final ingredients = _ingredients.text.trim();
      if (saved != null && savedCode.isNotEmpty) {
        await app.rememberUserBarcode(
          code: savedCode,
          brand: saved.brand,
          name: saved.name,
          spec: saved.spec,
          ingredients: ingredients,
          imageUrl: saved.photoPath,
          ask: () => confirmBarcodeShare(context),
        );
      }
      if (ingredients.isNotEmpty) {
        await app.saveRecognitionDraft(
          RecognitionDraft(
            id: 'facts:$id',
            kind: 'facts',
            updatedAt: app.now.toUtc(),
            barcode: savedCode,
            brand: brand,
            name: name,
            spec: spec,
            ingredients: ingredients,
            productId: id,
          ),
        );
      }
      await app.removeRecognitionDraft(
        recognitionDraftId(barcode: savedCode, photoPath: _photo),
      );
      if (savedCode.isEmpty) {
        await app.removeRecognitionDraft(recognitionDraftId(photoPath: _photo));
        await app.removeRecognitionDraft('latest');
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

  void _openPack({required bool camera}) {
    if (widget.productId != null) {
      _readPack(camera ? ImageSource.camera : ImageSource.gallery);
      return;
    }
    final code = Uri.encodeComponent(widget.barcode.trim());
    final shot = camera ? 'shot=1' : 'album=1';
    context.push('/pack?$shot&code=$code');
  }

  void _captureDraft() {
    if (!_ready) return;
    _draftTail = _draftTail.then((_) => _writeDraft());
  }

  Future<void> _writeDraft() async {
    if (!mounted) return;
    final app = AppScope.of<AppController>(context);
    final brand = _brand.text.trim();
    final name = _name.text.trim();
    final spec = _specCustom ? _specText.text.trim() : _spec;
    final flavor = _flavorCustom ? _flavorText.text.trim() : _flavor;
    final code = widget.barcode.trim();
    final draft = RecognitionDraft(
      id: recognitionDraftId(barcode: code, photoPath: _photo),
      kind: _photo == null ? 'scan' : 'ocr',
      updatedAt: app.now.toUtc(),
      barcode: code,
      brand: brand,
      name: name,
      spec: spec,
      flavor: flavor,
      formKey: foodFormKey(_form),
      customForm: _formCustom ? _formText.text.trim() : '',
      ingredients: _ingredients.text.trim(),
      photoPath: _photo,
      production: _production,
      expiry: _expiry,
      expiryFromOcr: _dateFromPhoto && _expiry != null,
      productId: _productId,
      pantryId: _pantryId,
      addBag: widget.addBag,
    );
    if (draft.isBlank) return;
    await app.saveRecognitionDraft(draft);
  }
}

bool _knownFlavor(String value) {
  return foodFlavors.where((item) => item != '鱼').contains(value);
}

bool _knownSpec(String value) => foodSpecs.contains(value);

FoodForm _formForLabel(String label) {
  for (final form in FoodForm.values) {
    if (formLabel(form) == label) return form;
  }
  return FoodForm.dry;
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
