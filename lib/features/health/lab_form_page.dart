import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/health/lab_catalog.dart';
import '../../domain/models.dart';
import '../../services/lab_ocr_service.dart';
import '../../services/photo_store.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class LabFormPage extends StatefulWidget {
  const LabFormPage({this.reportId, this.kind, this.checkupItemId, super.key});

  final int? reportId;
  final LabKind? kind;
  final String? checkupItemId;

  @override
  State<LabFormPage> createState() => _LabFormPageState();
}

class _LabFormPageState extends State<LabFormPage> {
  final _photosStore = PhotoStore();
  var _kind = LabKind.cbc;
  DateTime? _date;
  var _photos = <String>[];
  var _values = <LabValue>[];
  var _ready = false;
  var _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final app = AppScope.of<AppController>(context);
    final existing = widget.reportId == null
        ? null
        : app.labById(widget.reportId!);
    _kind = existing?.kind ?? widget.kind ?? LabKind.cbc;
    _date = dateOnly(existing?.takenOn ?? app.now);
    _photos = [...?existing?.photos];
    _values = [...?existing?.values];
    _ready = true;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null || _date == null) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: zhuajiBar('化验单'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final known = {for (final value in _values) value.code};
    final offer = _offerKinds();
    final missing = [
      for (final item in labCatalog)
        if (offer.contains(item.kind) && !known.contains(item.code)) item,
    ];
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar(widget.reportId == null ? '记化验单' : '这份化验'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in LabKind.values)
                ChoiceChip(
                  label: Text(labKindLabel(kind)),
                  selected: _kind == kind,
                  selectedColor: AppColors.of(context).brandTint,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
          DateChips(
            label: '日期',
            date: _date!,
            today: app.now,
            onChanged: (value) => setState(() => _date = value),
          ),
          const SizedBox(height: 8),
          if (_photos.isEmpty)
            const EmptyHint(title: '还没有原图', body: '拍照或从相册选，可以多张')
          else
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _PhotoTile(
                        path: _photos[i],
                        onOpen: () => _zoom(_photos[i]),
                        onRemove: () => setState(() => _photos.removeAt(i)),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _add(ImageSource.camera),
                  child: const Text('拍照'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _add(ImageSource.gallery),
                  child: const Text('相册'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _recognize,
            child: const Text('识别化验单'),
          ),
          const SizedBox(height: 16),
          if (_values.isNotEmpty) const SectionLabel('读到的'),
          for (final value in _ordered()) ...[
            const SizedBox(height: 8),
            _ValueCard(
              value: value,
              history: _history(app, value),
              onTap: () => _edit(value),
            ),
          ],
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionLabel('没读到的，点一下补'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in missing)
                  ActionChip(
                    label: Text(item.name),
                    onPressed: () => _addAnalyte(item),
                  ),
              ],
            ),
          ],
          if (_kind == LabKind.urine || _kind == LabKind.imaging) ...[
            const SizedBox(height: 12),
            Text(
              '尿检和影像先存原图。要补血常规或生化的数字，点上面的类型。',
              style: zhuaji.copyWith(
                fontSize: 12,
                height: 1.4,
                color: AppColors.of(context).muted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            labDisclaimer,
            style: zhuaji.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.of(context).brandDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            labRangeSource,
            style: zhuaji.copyWith(
              fontSize: 12,
              height: 1.4,
              color: AppColors.of(context).muted,
            ),
          ),
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
              if (widget.reportId != null)
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

  Set<LabKind> _offerKinds() => switch (_kind) {
    LabKind.cbc => {LabKind.cbc},
    LabKind.chem => {LabKind.chem},
    LabKind.other => {LabKind.cbc, LabKind.chem},
    _ => const {},
  };

  List<LabValue> _ordered() {
    final order = [for (final item in labCatalog) item.code];
    final copy = [..._values];
    copy.sort((a, b) => order.indexOf(a.code).compareTo(order.indexOf(b.code)));
    return copy;
  }

  List<({DateTime date, double value})> _history(
    AppController app,
    LabValue current,
  ) {
    final points = <({DateTime date, double value})>[];
    for (final point in app.labTrend(current.code)) {
      if (point.reportId == widget.reportId) continue;
      final base = baseValue(point.value);
      if (base == null) continue;
      points.add((date: point.date, value: base));
    }
    final now = baseValue(current);
    if (now != null) points.add((date: _date!, value: now));
    return points;
  }

  Future<void> _edit(LabValue value) async {
    final analyte = analyteByCode(value.code);
    if (analyte == null) return;
    final result = await showLabEditor(context, analyte, current: value);
    if (result == null || !mounted) return;
    setState(() {
      _values = [
        for (final item in _values)
          if (item.code != value.code) item,
        if (!result.remove && result.value != null) result.value!,
      ];
    });
  }

  Future<void> _addAnalyte(LabAnalyte analyte) async {
    final result = await showLabEditor(context, analyte);
    if (result == null || result.remove || result.value == null || !mounted) {
      return;
    }
    setState(() {
      _values = [
        for (final item in _values)
          if (item.code != analyte.code) item,
        result.value!,
      ];
    });
  }

  Future<void> _add(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = source == ImageSource.gallery
          ? await picker.pickMultiImage(maxWidth: 2000, imageQuality: 85)
          : [
              await picker.pickImage(
                source: source,
                maxWidth: 2000,
                imageQuality: 85,
              ),
            ].whereType<XFile>().toList();
      if (picked.isEmpty || !mounted) return;
      setState(() => _busy = true);
      final stored = <String>[];
      for (final file in picked) {
        stored.add(await _photosStore.persist(file.path, frameSubject: false));
      }
      if (!mounted) return;
      setState(() => _photos = [..._photos, ...stored]);
    } catch (_) {
      if (!mounted) return;
      showMessage(context, '没打开相册');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recognize() async {
    if (_photos.isEmpty) {
      showMessage(context, '先拍一张');
      return;
    }
    setState(() => _busy = true);
    try {
      final read = await const LabOcrService().readFiles(_photos);
      if (!mounted) return;
      if (read.isEmpty) {
        showMessage(context, '没认出指标，点下面的名字补');
        return;
      }
      setState(() {
        final manual = {
          for (final item in _values)
            if (item.source == LabValueSource.manual) item.code: item,
        };
        final next = <String, LabValue>{
          for (final item in _values) item.code: item,
        };
        for (final item in read) {
          if (manual.containsKey(item.code)) continue;
          next[item.code] = item;
        }
        _values = next.values.toList();
      });
      showMessage(context, '认出 ${read.length} 项，点一下就能改');
    } catch (_) {
      if (!mounted) return;
      showMessage(context, '识别没完成');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _zoom(String path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.of(context).scrim,
          appBar: AppBar(
            backgroundColor: AppColors.of(context).scrim,
            foregroundColor: AppColors.of(context).onScrim,
            title: const Text('原图'),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.file(File(path)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null || _date == null) return;
    setState(() => _busy = true);
    try {
      final existing = widget.reportId == null
          ? null
          : app.labById(widget.reportId!);
      await app.saveLab(
        LabDraft(
          id: widget.reportId,
          catId: cat.id,
          kind: _kind,
          takenOn: _date!,
          photos: _photos,
          checkupItemId: existing?.checkupItemId ?? widget.checkupItemId,
        ),
        values: _values,
      );
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/labs');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final id = widget.reportId;
    if (id == null) return;
    if (!await confirmDelete(context, '删掉这份？')) return;
    if (!mounted) return;
    await AppScope.of<AppController>(context).removeLab(id);
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/labs');
    }
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.path,
    required this.onOpen,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(path),
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: '去掉这张',
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.of(context).scrimSoft,
                minimumSize: const Size(48, 48),
                fixedSize: const Size(48, 48),
              ),
              icon: Icon(
                Icons.close,
                size: 18,
                color: AppColors.of(context).onScrim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.value,
    required this.history,
    required this.onTap,
  });

  final LabValue value;
  final List<({DateTime date, double value})> history;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reading = readLabValue(value);
    final analyte = reading?.analyte ?? analyteByCode(value.code);
    final flag = reading?.flag;
    final colors = AppColors.of(context);
    final color = switch (flag) {
      LabFlag.high => colors.danger,
      LabFlag.low => colors.low,
      LabFlag.normal => colors.olive,
      null => colors.muted,
    };
    return QuietCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  analyte == null
                      ? value.code
                      : '${analyte.name} ${analyte.code}',
                  style: zhuaji.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                reading?.flagLabel ?? '点一下改',
                style: zhuaji.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${formatLabNumber(value.value, analyte?.decimals ?? 1)} ${value.unit}',
            style: zhuaji.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (reading != null) ...[
            const SizedBox(height: 4),
            Text(reading.sentence, style: zhuaji.copyWith(height: 1.35)),
            const SizedBox(height: 2),
            Text(
              '${reading.fromReport ? '按化验单' : '常用范围'} ${formatLabNumber(reading.low, analyte?.decimals ?? 1)}-${formatLabNumber(reading.high, analyte?.decimals ?? 1)} ${value.unit}',
              style: zhuaji.copyWith(
                fontSize: 12,
                color: AppColors.of(context).muted,
              ),
            ),
          ],
          if (history.length >= 2) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparkPainter([
                  for (final point in history) point.value,
                ], AppColors.of(context)),
              ),
            ),
            Text(
              '${formatMonthDay(history.first.date)}-${formatMonthDay(history.last.date)} 的变化',
              style: zhuaji.copyWith(
                fontSize: 12,
                color: AppColors.of(context).muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.colors);

  final List<double> values;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final span = high - low == 0 ? 1.0 : high - low;
    final paint = Paint()
      ..color = colors.brandDeep
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y =
          size.height - ((values[i] - low) / span) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.values != values;
}

class LabEdit {
  const LabEdit.value(this.value) : remove = false;
  const LabEdit.remove() : value = null, remove = true;

  final LabValue? value;
  final bool remove;
}

Future<LabEdit?> showLabEditor(
  BuildContext context,
  LabAnalyte analyte, {
  LabValue? current,
}) {
  final initialUnit = analyte.unitFor(current?.unit ?? analyte.base.label);
  var unit = initialUnit;
  var shown = current == null
      ? (analyte.low + analyte.high) / 2 / unit.toBase
      : current.value * analyte.unitFor(current.unit).toBase / unit.toBase;
  return showModalBottomSheet<LabEdit>(
    context: context,
    isDismissible: true,
    builder: (context) => SafeArea(
      child: StatefulBuilder(
        builder: (context, setSheet) {
          final step = switch (analyte.decimals) {
            0 => 1.0,
            1 => 0.1,
            _ => 0.01,
          };
          void nudge(double times) {
            setSheet(() {
              shown = (shown + step * times).clamp(0, 100000).toDouble();
            });
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  analyte.name,
                  style: zhuaji.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatLabNumber(shown, analyte.decimals)} ${unit.label}',
                  style: zhuaji.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (analyte.units.length > 1)
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final item in analyte.units)
                        ChoiceChip(
                          label: Text(item.label),
                          selected: item.label == unit.label,
                          selectedColor: AppColors.of(context).brandTint,
                          onSelected: (_) => setSheet(() {
                            final base = shown * unit.toBase;
                            unit = item;
                            shown = base / item.toBase;
                          }),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => nudge(-10),
                      child: const Text('少很多'),
                    ),
                    OutlinedButton(
                      onPressed: () => nudge(-1),
                      child: const Text('少一点'),
                    ),
                    OutlinedButton(
                      onPressed: () => nudge(1),
                      child: const Text('多一点'),
                    ),
                    OutlinedButton(
                      onPressed: () => nudge(10),
                      child: const Text('多很多'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    LabEdit.value(
                      LabValue(
                        code: analyte.code,
                        value: double.parse(
                          shown.toStringAsFixed(analyte.decimals),
                        ),
                        unit: unit.label,
                        source: LabValueSource.manual,
                        printedLow: current?.printedLow,
                        printedHigh: current?.printedHigh,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('用这个'),
                ),
                if (current != null)
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, const LabEdit.remove()),
                    child: const Text('去掉这项'),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
