import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../domain/parsing/vaccine_sticker_parser.dart';
import '../../services/photo_store.dart';
import '../../services/vaccine_ocr_service.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class StickerPage extends StatefulWidget {
  const StickerPage({this.initial, super.key});

  final VaccineStickerRead? initial;

  @override
  State<StickerPage> createState() => _StickerPageState();
}

class _StickerPageState extends State<StickerPage> {
  static const _known = ['猫三联', '狂犬'];
  String? _name;
  DateTime? _given;
  String? _batch;
  var _busy = false;
  var _read = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == null || initial.isEmpty) return;
    _name = initial.name;
    _given = initial.givenOn;
    _batch = initial.batch;
    _read = true;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: zhuajiBar('疫苗贴纸'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final given = _given ??= dateOnly(app.now);
    final name = _name ??= '猫三联';
    final choices = [
      ..._known,
      if (name.isNotEmpty && !_known.contains(name)) name,
    ];
    final next = nextVaccineDate(cat.birthday, given);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('疫苗贴纸'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          Text(
            _read
                ? '认出来了，对一下再记下。不对就重拍。'
                : '拍下贴纸上的字。名称、批号和日期会填在这里，确认后才保存。',
            style: zhuaji.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          QuietCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in choices)
                      ChoiceChip(
                        label: Text(label),
                        selected: name == label,
                        selectedColor: AppColors.tintCoral,
                        onSelected: (_) => setState(() => _name = label),
                      ),
                  ],
                ),
                DateChips(
                  label: '接种',
                  date: given,
                  today: app.now,
                  onChanged: (value) => setState(() => _given = value),
                ),
                Text(
                  _batch == null || _batch!.isEmpty ? '还没有批号' : '批号 $_batch',
                  style: zhuaji.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '下次 ${formatDate(next)}',
                  style: zhuaji.copyWith(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _shoot,
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: Text(_read ? '重拍' : '拍贴纸'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await app.saveVaccine(
                      VaccineDraft(
                        catId: cat.id,
                        name: name,
                        givenOn: given,
                        nextDue: next,
                        batch: _batch,
                      ),
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (!context.mounted) return;
                    showMessage(context, '记下了');
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/vaccines');
                    }
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('记下'),
          ),
        ),
      ),
    );
  }

  Future<void> _shoot() async {
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      showMessage(context, '测试里不打开相机');
      return;
    }
    setState(() => _busy = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final stored = await PhotoStore().persist(
        picked.path,
        frameSubject: false,
      );
      final read = await const VaccineOcrService().readFile(stored);
      if (!mounted) return;
      setState(() {
        _read = true;
        if (read.name != null && read.name!.isNotEmpty) _name = read.name;
        if (read.givenOn != null) _given = read.givenOn;
        _batch = read.batch;
      });
      if (read.isEmpty && mounted) {
        showMessage(context, '没认出字，可以重拍或自己点选');
      }
    } catch (_) {
      if (!mounted) return;
      showMessage(context, '没打开相机');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
