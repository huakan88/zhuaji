import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../services/photo_store.dart';
import '../../state/app_controller.dart';
import '../health/known_or_custom.dart';

class CatFormPage extends StatefulWidget {
  const CatFormPage({this.catId, super.key});

  final int? catId;

  @override
  State<CatFormPage> createState() => _CatFormPageState();
}

class _CatFormPageState extends State<CatFormPage> {
  static const _breeds = [
    '中华田园猫',
    '英国短毛猫',
    '美国短毛猫',
    '布偶猫',
    '暹罗猫',
    '俄罗斯蓝猫',
    '缅因猫',
    '异国短毛猫',
  ];

  final _name = TextEditingController();
  final _breedText = TextEditingController();
  final _photos = PhotoStore();
  String? _avatar;
  String _breed = '';
  var _breedCustom = false;
  var _loaded = false;
  var _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final existing = widget.catId == null
        ? null
        : AppScope.of<AppController>(context).catById(widget.catId!);
    if (existing != null) {
      _name.text = existing.name;
      _avatar = existing.avatarPath;
      final breed = existing.breed?.trim() ?? '';
      if (breed.isNotEmpty && !_breeds.contains(breed)) {
        _breedCustom = true;
        _breedText.text = breed;
      } else {
        _breed = breed;
      }
    }
    _loaded = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _breedText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar(widget.catId == null ? '建档' : '改名'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(child: CatAvatar(path: _avatar, size: 140, selected: true)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pick(ImageSource.camera),
                  child: const Text('拍照'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pick(ImageSource.gallery),
                  child: const Text('相册'),
                ),
              ),
            ],
          ),
          Align(
            child: TextButton(
              onPressed: _busy ? null : _sample,
              child: const Text('示例'),
            ),
          ),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: '名字'),
          ),
          const SizedBox(height: 16),
          const SectionLabel('品种'),
          const SizedBox(height: 8),
          KnownOrCustom(
            known: _breeds,
            selected: _breed,
            custom: _breedCustom,
            controller: _breedText,
            hint: '品种',
            onKnown: (label) => setState(() {
              _breedCustom = false;
              _breed = _breed == label ? '' : label;
            }),
            onCustom: () => setState(() => _breedCustom = true),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final stored = file.path.startsWith('asset:')
          ? file.path
          : await _photos.persist(file.path);
      if (!mounted) return;
      setState(() => _avatar = stored);
    } catch (_) {
      if (!mounted) return;
      showMessage(context, '没打开相机');
    }
  }

  void _sample() {
    setState(() => _avatar = 'asset:assets/cats/cat-orange.jpg');
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showMessage(context, '先写名字');
      return;
    }
    if (_avatar == null) {
      showMessage(context, '先拍一张');
      return;
    }
    final typedBreed = _breedText.text.trim();
    if (_breedCustom && typedBreed.isEmpty) {
      showMessage(context, '先写上品种');
      return;
    }
    final breed = _breedCustom ? typedBreed : (_breed.isEmpty ? null : _breed);
    final app = AppScope.of<AppController>(context);
    final existing = widget.catId == null ? null : app.catById(widget.catId!);
    setState(() => _busy = true);
    try {
      await app.saveCat(
        CatDraft(
          id: existing?.id,
          name: name,
          sex: existing?.sex ?? CatSex.unknown,
          neutered: existing?.neutered ?? false,
          birthday: existing?.birthday,
          coatColor: existing?.coatColor,
          breed: breed,
          goal: existing?.goal ?? CareGoal.maintain,
          notes: existing?.notes ?? '',
          avatarPath: _avatar,
          recognitionDetail: existing?.recognitionDetail,
          recognitionSource: existing?.recognitionSource,
        ),
      );
      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
