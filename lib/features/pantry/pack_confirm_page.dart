import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/food/barcode_lookup.dart';
import '../../domain/food/pack_confirm.dart';
import '../../domain/food/recognition_draft.dart';
import '../../domain/models.dart';
import '../../services/pack_ocr_service.dart';
import '../../services/photo_store.dart';
import '../../services/system_settings.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

/// Confirm screen after a pack photo, and after an unknown barcode is photographed.
///
/// Nothing is written into the pantry until 「存进粮仓」. Every field can be typed.
/// An empty expiry is kept empty and will not schedule a near-expiry reminder.
class PackConfirmPage extends StatefulWidget {
  const PackConfirmPage({
    this.barcode = '',
    this.draftId,
    this.openCamera = false,
    this.openGallery = false,
    super.key,
  });

  final String barcode;
  final String? draftId;
  final bool openCamera;
  final bool openGallery;

  @override
  State<PackConfirmPage> createState() => _PackConfirmPageState();
}

class _PackConfirmPageState extends State<PackConfirmPage> {
  final _barcode = TextEditingController();
  final _brand = TextEditingController();
  final _name = TextEditingController();
  final _spec = TextEditingController();
  final _ingredients = TextEditingController();
  final _brandFocus = FocusNode();
  final _photos = PhotoStore();
  final _settings = const SystemSettings();
  var _marks = <String, FieldMark>{
    for (final key in packFieldKeys) key: FieldMark.missing,
  };
  DateTime? _production;
  DateTime? _expiry;
  PackFailure? _failure;
  String? _photo;
  String _flavor = '';
  FoodForm? _form;
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
    for (final entry in <(String, TextEditingController)>[
      ('brand', _brand),
      ('name', _name),
      ('spec', _spec),
      ('ingredients', _ingredients),
    ]) {
      entry.$2.addListener(() => _touch(entry.$1, entry.$2.text));
    }
    _barcode.addListener(() {
      if (_silent || !_ready) return;
      _persist();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    _load(app.draftFor(id: widget.draftId, barcode: widget.barcode));
    _ready = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _persist();
      if (_askedCamera) return;
      _askedCamera = true;
      if (Platform.environment['FLUTTER_TEST'] == 'true') return;
      if (widget.openCamera) _shoot(ImageSource.camera);
      if (widget.openGallery) _shoot(ImageSource.gallery);
    });
  }

  @override
  void dispose() {
    _barcode.dispose();
    _brand.dispose();
    _name.dispose();
    _spec.dispose();
    _ingredients.dispose();
    _brandFocus.dispose();
    super.dispose();
  }

  void _load(RecognitionDraft? draft) {
    _silent = true;
    final code = widget.barcode.trim().isNotEmpty
        ? widget.barcode.trim()
        : (draft?.barcode ?? '');
    _barcode.text = code;
    _brand.text = draft?.brand ?? '';
    _name.text = draft?.name ?? '';
    _spec.text = draft?.spec ?? '';
    _ingredients.text = draft?.ingredients ?? '';
    _production = draft?.production;
    _expiry = draft?.expiry;
    _photo = draft?.photoPath;
    _productId = draft?.productId;
    _pantryId = draft?.pantryId;
    _flavor = draft?.flavor ?? '';
    if (draft != null && draft.formKey.isNotEmpty) _form = formFromDraft(draft);
    _marks = marksForDraft(
      stored: draft?.marks ?? const {},
      values: _valueMap(),
    );
    _failure = parsePackFailure(draft?.failure ?? '');
    _silent = false;
  }

  Map<String, String> _valueMap() => {
    'brand': _brand.text,
    'name': _name.text,
    'spec': _spec.text,
    'ingredients': _ingredients.text,
    'production': _production == null ? '' : '1',
    'expiry': _expiry == null ? '' : '1',
  };

  void _touch(String key, String value) {
    if (_silent || !_ready) return;
    final next = markAfterEdit(value);
    if (_marks[key] == next && value.trim().isNotEmpty) {
      _persist();
      return;
    }
    setState(() => _marks[key] = next);
    _persist();
  }

  int get _filled =>
      _valueMap().values.where((item) => item.trim().isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final leads = leadingIngredients(_ingredients.text);
    final photo = _photo;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result == null) _persist();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: zhuajiBar('核对包装'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            Text(
              confirmProgress(_filled, _marks),
              style: zhuaji.copyWith(fontSize: 13, color: colors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              onDeviceOcrCopy,
              style: zhuaji.copyWith(fontSize: 12, color: colors.muted),
            ),
            if (_failure != null) ...[
              const SizedBox(height: 12),
              _FailureCard(
                failure: _failure!,
                busy: _busy,
                onSettings: _openSettings,
                onRetake: () => _shoot(ImageSource.camera),
              ),
            ],
            if (photo != null && File(photo).existsSync()) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.l),
                child: Image.file(
                  File(photo),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _barcode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '条码'),
            ),
            const SizedBox(height: 8),
            _field(_brand, '品牌', 'brand', focus: _brandFocus),
            _field(_name, '品名', 'name'),
            _field(_spec, '规格', 'spec'),
            _field(_ingredients, '配料', 'ingredients', lines: 4),
            if (leads.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ingredientLeadCaption,
                style: zhuaji.copyWith(fontSize: 12, color: colors.muted),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: zhuaji.copyWith(fontSize: 15, height: 1.4),
                  children: [
                    for (var i = 0; i < leads.length; i++) ...[
                      if (i > 0) const TextSpan(text: '、'),
                      TextSpan(
                        text: leads[i],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            _dateRow(
              label: '生产',
              keyName: 'production',
              date: _production,
              onPick: (value) => setState(() {
                _production = value;
                _marks['production'] = value == null
                    ? FieldMark.missing
                    : FieldMark.edited;
              }),
            ),
            _dateRow(
              label: '到期',
              keyName: 'expiry',
              date: _expiry,
              onPick: (value) => setState(() {
                _expiry = value;
                _marks['expiry'] = value == null
                    ? FieldMark.missing
                    : FieldMark.edited;
              }),
            ),
            if (_expiry == null) ...[
              const SizedBox(height: 8),
              Text(
                emptyExpiryCopy,
                style: zhuaji.copyWith(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.muted,
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
                  child: const Text('存进粮仓'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _shoot(ImageSource.camera),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('重拍'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _brandFocus.requestFocus(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('手填'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String key, {
    FocusNode? focus,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              minLines: 1,
              maxLines: lines,
              textInputAction: lines > 1
                  ? TextInputAction.newline
                  : TextInputAction.next,
              decoration: InputDecoration(labelText: label),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: _Badge(_marks[key] ?? FieldMark.missing),
          ),
        ],
      ),
    );
  }

  Widget _dateRow({
    required String label,
    required String keyName,
    required DateTime? date,
    required ValueChanged<DateTime?> onPick,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DateLine(
                label: label,
                date: date,
                placeholder: '未识别',
                onTap: () async {
                  final picked = await pickDate(
                    context,
                    date ?? dateOnly(AppScope.of<AppController>(context).now),
                  );
                  if (picked == null) return;
                  onPick(dateOnly(picked));
                  _persist();
                },
              ),
            ),
            _Badge(_marks[keyName] ?? FieldMark.missing),
          ],
        ),
        if (date != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                onPick(null);
                _persist();
              },
              child: Text(keyName == 'expiry' ? '清除（保持为空）' : '清除生产日期'),
            ),
          ),
      ],
    );
  }

  Future<void> _shoot(ImageSource source) async {
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
      final capture = await const PackOcrService().captureFile(
        stored,
        extraBrands: brands,
      );
      if (!mounted) return;
      _applySheet(
        sheetFromRead(capture.read, lines: capture.lines),
        photo: stored,
      );
      _persist();
    } catch (error) {
      if (!mounted) return;
      if (cameraDenied(error)) {
        setState(() => _failure = PackFailure.camera);
        _persist();
        return;
      }
      showMessage(context, '没打开相机。可以手填。');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _applySheet(PackSheet sheet, {String? photo}) {
    _silent = true;
    void take(
      String key,
      TextEditingController controller,
      String value,
      FieldMark mark,
    ) {
      if (_marks[key] == FieldMark.edited) return;
      controller.text = value;
      _marks[key] = mark;
    }

    setState(() {
      take('brand', _brand, sheet.brand, sheet.brandMark);
      take('name', _name, sheet.name, sheet.nameMark);
      take('spec', _spec, sheet.spec, sheet.specMark);
      take(
        'ingredients',
        _ingredients,
        sheet.ingredients,
        sheet.ingredientsMark,
      );
      if (_marks['production'] != FieldMark.edited) {
        _production = sheet.production;
        _marks['production'] = sheet.productionMark;
      }
      if (_marks['expiry'] != FieldMark.edited) {
        _expiry = sheet.expiry;
        _marks['expiry'] = sheet.expiryMark;
      }
      _failure = sheet.failure;
      if (photo != null) _photo = photo;
      if (_flavor.isEmpty && sheet.flavor.isNotEmpty) _flavor = sheet.flavor;
      _form ??= sheet.form;
    });
    _silent = false;
  }

  Future<void> _openSettings() async {
    final opened = await _settings.open();
    if (!mounted || opened) return;
    showMessage(context, '请到系统设置里打开花爪的相机，或直接手填。');
  }

  Future<void> _save() async {
    final brand = _brand.text.trim();
    final name = _name.text.trim();
    if (brand.isEmpty || name.isEmpty) {
      showMessage(context, '先写上品牌和品名');
      return;
    }
    if (askBeforeSave(_marks)) {
      final ok = await _askUnchecked();
      if (!ok || !mounted) return;
    }
    final app = AppScope.of<AppController>(context);
    final code = _barcode.text.trim();
    if (_barcodeTaken(app, code, _productId)) {
      showMessage(context, '这个条码已经绑在别的猫粮上');
      return;
    }
    setState(() => _busy = true);
    try {
      final form = _form ?? guessLookupForm(name, _spec.text.trim());
      final id = await app.saveFood(
        FoodDraft(
          id: _productId,
          brand: brand,
          name: name,
          spec: _spec.text.trim(),
          foodForm: form,
          storageMethod: _storage(form),
          afterOpenDays: _days(form),
          flavor: _flavor,
          isCustom: true,
          photoPath: _photo,
        ),
        barcode: code,
      );
      _productId = id;
      _pantryId = await app.savePantry(
        PantryDraft(
          id: _pantryId,
          productId: id,
          productionDate: _production,
          expiryDate: _expiry,
          dateSource: _bagSource(),
          afterOpenDays: _days(form),
        ),
      );
      final ingredients = _ingredients.text.trim();
      if (code.isNotEmpty) {
        await app.rememberUserBarcode(
          code: code,
          brand: brand,
          name: name,
          spec: _spec.text.trim(),
          ingredients: ingredients,
          imageUrl: _photo,
          ask: () => confirmBarcodeShare(context),
        );
      }
      if (ingredients.isNotEmpty) {
        await app.saveRecognitionDraft(
          RecognitionDraft(
            id: 'facts:$id',
            kind: 'facts',
            updatedAt: app.now.toUtc(),
            barcode: code,
            brand: brand,
            name: name,
            spec: _spec.text.trim(),
            ingredients: ingredients,
            productId: id,
          ),
        );
      }
      await _dropDrafts(app, code);
      if (!mounted) return;
      showMessage(
        context,
        _expiry == null ? '已存进粮仓。到期日没读到，这袋不会提醒临期。' : '已存进粮仓',
      );
      context.go('/pantry');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  DateSource _bagSource() {
    if (_expiry != null) {
      return _marks['expiry'] == FieldMark.edited
          ? DateSource.manual
          : DateSource.ocr;
    }
    if (_production != null) {
      return _marks['production'] == FieldMark.edited
          ? DateSource.manual
          : DateSource.ocr;
    }
    return DateSource.none;
  }

  Future<bool> _askUnchecked() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(uncheckedSaveTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('再看看'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('存进粮仓'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _persist() {
    if (!_ready) return;
    _draftTail = _draftTail.then((_) => _writeDraft());
  }

  Future<void> _writeDraft() async {
    if (!mounted) return;
    final app = AppScope.of<AppController>(context);
    final code = _barcode.text.trim();
    final draft = RecognitionDraft(
      id: _draftKey,
      kind: 'ocr',
      updatedAt: app.now.toUtc(),
      barcode: code,
      brand: _brand.text.trim(),
      name: _name.text.trim(),
      spec: _spec.text.trim(),
      flavor: _flavor,
      formKey: _form == null ? '' : foodFormKey(_form!),
      ingredients: _ingredients.text.trim(),
      photoPath: _photo,
      production: _production,
      expiry: _expiry,
      expiryFromOcr: _expiry != null && _marks['expiry'] != FieldMark.edited,
      productId: _productId,
      pantryId: _pantryId,
      addBag: true,
      marks: {for (final entry in _marks.entries) entry.key: entry.value.name},
      failure: _failure?.name ?? '',
    );
    if (draft.isBlank) {
      await app.removeRecognitionDraft(draft.id);
      return;
    }
    await app.saveRecognitionDraft(draft);
  }

  String get _draftKey {
    final given = widget.draftId?.trim() ?? '';
    if (given.isNotEmpty) return given;
    return recognitionDraftId(barcode: _barcode.text, photoPath: _photo);
  }

  Future<void> _dropDrafts(AppController app, String code) async {
    await app.removeRecognitionDraft(_draftKey);
    await app.removeRecognitionDraft(
      recognitionDraftId(barcode: code, photoPath: _photo),
    );
    await app.removeRecognitionDraft(recognitionDraftId(photoPath: _photo));
    await app.removeRecognitionDraft('latest');
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.mark);

  final FieldMark mark;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final missing = mark == FieldMark.missing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: missing ? colors.field : colors.brandTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        fieldMarkLabel(mark),
        style: zhuaji.copyWith(
          fontSize: 12,
          color: missing ? colors.muted : colors.brandDeep,
        ),
      ),
    );
  }
}

class _FailureCard extends StatelessWidget {
  const _FailureCard({
    required this.failure,
    required this.busy,
    required this.onSettings,
    required this.onRetake,
  });

  final PackFailure failure;
  final bool busy;
  final VoidCallback onSettings;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return QuietCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            failureTitle(failure),
            style: zhuaji.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            failureBody(failure),
            style: zhuaji.copyWith(
              fontSize: 13,
              height: 1.4,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (failure == PackFailure.camera)
                OutlinedButton(
                  onPressed: busy ? null : onSettings,
                  child: const Text('去设置'),
                ),
              OutlinedButton(
                onPressed: busy ? null : onRetake,
                child: const Text('重拍'),
              ),
            ],
          ),
        ],
      ),
    );
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
