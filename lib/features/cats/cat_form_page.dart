import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../services/photo_store.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class CatFormPage extends StatefulWidget {
  const CatFormPage({this.catId, super.key});

  final int? catId;

  @override
  State<CatFormPage> createState() => _CatFormPageState();
}

class _CatFormPageState extends State<CatFormPage> {
  final _name = TextEditingController();
  final _coat = TextEditingController();
  final _breed = TextEditingController();
  final _notes = TextEditingController();
  final _photos = PhotoStore();
  CatSex _sex = CatSex.unknown;
  CareGoal _goal = CareGoal.maintain;
  bool _neutered = true;
  DateTime? _birthday;
  String? _avatar;
  String? _hint;
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
      _coat.text = existing.coatColor ?? '';
      _breed.text = existing.breed ?? '';
      _notes.text = existing.notes;
      _sex = existing.sex;
      _goal = existing.goal;
      _neutered = existing.neutered;
      _birthday = existing.birthday;
      _avatar = existing.avatarPath;
      _hint = existing.recognitionDetail;
    }
    _loaded = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _coat.dispose();
    _breed.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.catId == null ? '新的猫咪' : '编辑资料')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: CatAvatar(path: _avatar, size: 112, selected: true),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _avatar == null || _busy ? null : _recognize,
            child: Text(_busy ? '正在识别…' : '识别毛色和大致品种'),
          ),
          if (_hint != null) ...[
            const SizedBox(height: 8),
            Text(_hint!, style: const TextStyle(color: AppColors.brown, height: 1.4)),
          ],
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: '名字')),
          const SizedBox(height: 12),
          DropdownButtonFormField<CatSex>(
            initialValue: _sex,
            decoration: const InputDecoration(labelText: '性别'),
            items: [
              for (final sex in CatSex.values)
                DropdownMenuItem(value: sex, child: Text(sexLabel(sex))),
            ],
            onChanged: (value) => setState(() => _sex = value ?? _sex),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('生日'),
            subtitle: Text(_birthday == null ? '未填' : formatDate(_birthday!)),
            trailing: const Icon(Icons.calendar_today_outlined, size: 18),
            onTap: () async {
              final picked = await pickDate(context, _birthday ?? DateTime.now());
              if (picked != null) setState(() => _birthday = picked);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('已绝育'),
            value: _neutered,
            onChanged: (value) => setState(() => _neutered = value),
          ),
          DropdownButtonFormField<CareGoal>(
            initialValue: _goal,
            decoration: const InputDecoration(labelText: '喂养目标'),
            items: [
              for (final goal in CareGoal.values)
                DropdownMenuItem(value: goal, child: Text(goalLabel(goal))),
            ],
            onChanged: (value) => setState(() => _goal = value ?? _goal),
          ),
          const SizedBox(height: 12),
          TextField(controller: _coat, decoration: const InputDecoration(labelText: '毛色')),
          const SizedBox(height: 12),
          TextField(controller: _breed, decoration: const InputDecoration(labelText: '大致品种')),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '备注'),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('保存')),
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
      if (file == null) {
        if (!mounted) return;
        setState(() => _hint = '没有打开相机或相册，可以稍后再试');
        showMessage(context, '没有打开相机或相册，可以稍后再试');
        return;
      }
      final stored = file.path.startsWith('asset:')
          ? file.path
          : await _photos.persist(file.path);
      if (!mounted) return;
      setState(() => _avatar = stored);
      await _recognize();
    } catch (_) {
      if (!mounted) return;
      setState(() => _hint = '没有打开相机或相册，可以稍后再试');
      showMessage(context, '没有打开相机或相册，可以稍后再试');
    }
  }

  Future<void> _recognize() async {
    final path = _avatar;
    if (path == null || path.startsWith('asset:')) {
      setState(() => _hint = '示例图不能跑端侧模型。换一张你拍的照片后再识别。');
      return;
    }
    setState(() => _busy = true);
    final app = AppScope.of<AppController>(context);
    final suggestion = await app.recognizer.recognize(path);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _coat.text = suggestion.coatColor;
      _breed.text = suggestion.breed;
      _hint =
          '${suggestion.detail} 置信度 ${(suggestion.confidence * 100).round()}%。来源：${suggestion.source == RecognitionSource.mlkit ? 'ML Kit' : '示例模型'}。';
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      showMessage(context, '先写一个名字');
      return;
    }
    final app = AppScope.of<AppController>(context);
    final existing = widget.catId == null ? null : app.catById(widget.catId!);
    final id = await app.saveCat(
      CatDraft(
        id: widget.catId,
        name: _name.text,
        sex: _sex,
        birthday: _birthday,
        neutered: _neutered,
        goal: _goal,
        coatColor: _coat.text,
        breed: _breed.text,
        avatarPath: _avatar,
        notes: _notes.text,
        isSample: existing?.isSample ?? false,
        recognitionSource: existing?.recognitionSource,
        recognitionConfidence: existing?.recognitionConfidence,
        recognitionDetail: _hint ?? existing?.recognitionDetail,
      ),
    );
    if (!mounted) return;
    if (widget.catId == null) {
      context.pushReplacement('/cat?id=$id');
    } else {
      context.pop();
    }
  }
}
