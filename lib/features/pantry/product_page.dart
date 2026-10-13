import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/copy.dart';
import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../domain/parsing/gs1_parser.dart';
import '../../domain/parsing/ocr_date_parser.dart';
import '../../services/date_ocr_service.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({required this.productId, this.pantryId, super.key});

  final int productId;
  final int? pantryId;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  DateTime? _production;
  DateTime? _expiry;
  String? _batch;
  DateSource _source = DateSource.none;
  var _bestBefore = false;
  var _ready = false;
  var _openToday = true;
  final _ocr = const DateOcrService();
  final _gs1 = const Gs1Parser();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    final entry = widget.pantryId == null
        ? null
        : app.pantryById(widget.pantryId!);
    _production = entry?.item.productionDate;
    _expiry = entry?.item.expiryDate;
    _batch = entry?.item.batch;
    _source = entry?.item.dateSource ?? DateSource.none;
    _ready = true;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final product = app.productById(widget.productId);
    if (product == null) {
      return const Scaffold(body: Center(child: Text('找不到这款猫粮')));
    }
    final entry = widget.pantryId == null
        ? null
        : app.pantryById(widget.pantryId!);
    return Scaffold(
      appBar: AppBar(title: const Text('这袋粮')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          FoodDateCard(
            brand: product.brand,
            name: product.name,
            spec: product.spec,
            form: formLabel(product.foodForm),
            storage: product.storageMethod,
            now: app.now,
            isSample: product.isSample,
            production: _production,
            expiry: _expiry,
            batch: _batch,
            source: sourceLabel(_source),
            openedAt: entry?.item.openedAt,
            afterOpenDays: entry?.openWindowDays ?? product.afterOpenDays,
            bestBeforeOnly: _bestBefore,
          ),
          if (product.kcalPer100g != null) ...[
            const SizedBox(height: 8),
            Text(
              '示例热量 ${product.kcalPer100g!.round()} kcal/100g。${product.isSample ? kSampleFoodNote : ''}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            kBarcodeNote,
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: Space.x4),
          FilledButton(onPressed: _scanGs1, child: const Text('扫描 GS1 日期码')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _scanText, child: const Text('拍摄印刷日期')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _editManually, child: const Text('手动填写日期')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              final parsed = _gs1.parse('(11)251012(17)270412(10)DEMO');
              _applyParsed(
                production: parsed.productionDate,
                expiry: parsed.suggestedExpiry,
                batch: parsed.batch,
                source: DateSource.gs1,
                bestBefore: parsed.expiryIsBestBefore,
              );
            },
            child: const Text('填入示例 GS1 日期'),
          ),
          const SizedBox(height: Space.x4),
          if (entry == null) ...[
            const Text(
              '开封日默认是今天',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('今天开封'),
                  selected: _openToday,
                  selectedColor: AppColors.coral,
                  onSelected: (_) => setState(() => _openToday = true),
                ),
                ChoiceChip(
                  label: const Text('还没开封'),
                  selected: !_openToday,
                  selectedColor: AppColors.coral,
                  onSelected: (_) => setState(() => _openToday = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: () => _save(app, product),
            child: Text(entry == null ? '登记到粮仓' : '保存日期'),
          ),
          if (entry != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: entry.item.openedAt == null
                  ? () => app.markOpened(entry)
                  : null,
              child: Text(
                entry.item.openedAt == null
                    ? '标记已开封'
                    : '已开封 ${formatDate(entry.item.openedAt!)}',
              ),
            ),
            TextButton(
              onPressed: () async {
                if (await confirmDelete(context, '从粮仓移出这袋？')) {
                  await app.removePantry(entry.item.id);
                  if (context.mounted) context.pop();
                }
              },
              child: const Text('移出粮仓'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _scanGs1() async {
    final raw = await context.push<String>('/scan?mode=gs1');
    if (raw == null || !mounted) return;
    final parsed = _gs1.parse(raw);
    if (!parsed.recognized) {
      showMessage(context, '没有解析出 GS1 日期，可以改用拍照或手动填写');
      return;
    }
    await _applyParsed(
      production: parsed.productionDate,
      expiry: parsed.suggestedExpiry,
      batch: parsed.batch,
      source: DateSource.gs1,
      bestBefore: parsed.expiryIsBestBefore,
    );
  }

  Future<void> _scanText() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final XFile? file;
    try {
      file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    } catch (_) {
      if (mounted) showMessage(context, '没有打开相机或相册，可以改用手动填写');
      return;
    }
    if (!mounted) return;
    if (file == null) {
      showMessage(context, '没有拿到照片，可以改用手动填写');
      return;
    }
    OcrDateParseResult parsed;
    try {
      parsed = await _ocr.readFile(file.path);
    } catch (error) {
      if (!mounted) return;
      showMessage(context, '文字识别没有完成：$error');
      return;
    }
    if (!mounted) return;
    if (!parsed.hasDate) {
      showMessage(context, '没有认出日期，用滚轮点选');
      await _editManually();
      return;
    }
    await _applyParsed(
      production: parsed.productionDate ?? _production,
      expiry: parsed.expiryDate ?? _expiry,
      batch: _batch,
      source: DateSource.ocr,
      bestBefore: false,
      note: parsed.expiryInferred
          ? '保质期由「${parsed.shelfLifeText}」和生产日期推算，请核对。'
          : null,
    );
  }

  Future<void> _editManually() async {
    final app = AppScope.of<AppController>(context);
    final production = await pickDateWheel(context, _production ?? app.now);
    if (!mounted || production == null) return;
    final expiry = await pickDateWheel(
      context,
      _expiry ?? addMonths(production, 18),
    );
    if (!mounted || expiry == null) return;
    await _applyParsed(
      production: production,
      expiry: expiry,
      batch: _batch,
      source: DateSource.manual,
      bestBefore: false,
    );
  }

  Future<void> _applyParsed({
    required DateTime? production,
    required DateTime? expiry,
    required String? batch,
    required DateSource source,
    required bool bestBefore,
    String? note,
  }) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认日期'),
        content: Text(
          '生产：${production == null ? '未识别' : formatDate(production)}\n'
          '保质期：${expiry == null ? '未识别' : formatDate(expiry)}\n'
          '${batch == null || batch.isEmpty ? '' : '批号：$batch\n'}'
          '${note ?? ''}\n请核对后再保存。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('采用'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    setState(() {
      _production = production;
      _expiry = expiry;
      _batch = batch;
      _source = source;
      _bestBefore = bestBefore;
    });
  }

  Future<void> _save(AppController app, FoodProduct product) async {
    final existing = widget.pantryId == null
        ? null
        : app.pantryById(widget.pantryId!);
    final id = await app.savePantry(
      PantryDraft(
        id: existing?.item.id,
        productId: product.id,
        productionDate: _production,
        expiryDate: _expiry,
        batch: _batch,
        dateSource: _source,
        openedAt: existing != null
            ? existing.item.openedAt
            : (_openToday ? app.now : null),
        afterOpenDays: existing?.item.afterOpenDays ?? product.afterOpenDays,
      ),
    );
    if (!mounted) return;
    showMessage(context, '已记入粮仓');
    if (widget.pantryId == null) {
      context.pushReplacement('/product?productId=${product.id}&pantryId=$id');
    }
  }
}
