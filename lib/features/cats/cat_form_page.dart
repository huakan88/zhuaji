import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../services/photo_store.dart';
import '../../state/app_controller.dart';

class CatFormPage extends StatefulWidget {
  const CatFormPage({this.catId, super.key});

  final int? catId;

  @override
  State<CatFormPage> createState() => _CatFormPageState();
}

class _CatFormPageState extends State<CatFormPage> {
  final _name = TextEditingController();
  final _photos = PhotoStore();
  String? _avatar;
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
    }
    _loaded = true;
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
          breed: existing?.breed,
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
