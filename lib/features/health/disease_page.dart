import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/disease_catalog.dart';
import '../../state/app_controller.dart';
import 'known_or_custom.dart';

class DiseaseLibraryPage extends StatefulWidget {
  const DiseaseLibraryPage({this.initialId, super.key});

  final String? initialId;

  @override
  State<DiseaseLibraryPage> createState() => _DiseaseLibraryPageState();
}

class _DiseaseLibraryPageState extends State<DiseaseLibraryPage> {
  final _customText = TextEditingController();
  String? _selected;
  var _custom = false;
  var _seeded = false;
  var _busy = false;

  void _seed(String? id) {
    if (_seeded) return;
    _seeded = true;
    if (id == null || id.isEmpty || diseaseById(id) != null) return;
    _custom = true;
    _customText.text = id;
  }

  @override
  void dispose() {
    _customText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final marked = <String>{
      for (final item in app.catConditions) item.diseaseId,
    };
    _seed(
      _selected ?? widget.initialId ?? (marked.isEmpty ? null : marked.first),
    );
    final selectedId =
        _selected ??
        widget.initialId ??
        (marked.isEmpty ? diseaseCatalog.first.id : marked.first);
    final known = diseaseById(selectedId);
    final disease = known ?? diseaseCatalog.first;
    final customName = _customText.text.trim();
    final already = cat == null
        ? false
        : app.conditionFor(_custom ? customName : disease.id) != null;
    final flag = disease.redFlags.isEmpty ? '' : disease.redFlags.first;
    final diet = _oneLine(disease.diet);
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('看病'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          KnownOrCustom(
            known: [for (final item in diseaseCatalog) item.name],
            selected: _custom ? '' : disease.name,
            custom: _custom,
            controller: _customText,
            hint: '病名',
            onKnown: (label) => setState(() {
              _custom = false;
              for (final item in diseaseCatalog) {
                if (item.name == label) {
                  _selected = item.id;
                  break;
                }
              }
            }),
            onCustom: () => setState(() => _custom = true),
          ),
          const SizedBox(height: 16),
          if (_custom)
            Text('按你写的名字记下，大约 180 天后再提醒。', style: zhuaji.copyWith(height: 1.35))
          else ...[
            Text('红灯', style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              flag.isEmpty ? '没有' : flag,
              style: zhuaji.copyWith(height: 1.35),
            ),
            const SizedBox(height: 12),
            Text('喂养', style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(diet, style: zhuaji.copyWith(height: 1.35)),
          ],
        ],
      ),
      bottomNavigationBar: cat == null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: () {
                    if (app.cats.isEmpty) {
                      context.push('/cat-form');
                    } else {
                      context.go('/cats');
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Text(app.cats.isEmpty ? '先建档案' : '去点一只猫'),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: (already && !_custom) || _busy
                      ? null
                      : () async {
                          final id = _custom
                              ? _customText.text.trim()
                              : disease.id;
                          if (id.isEmpty) {
                            showMessage(context, '先写上病名');
                            return;
                          }
                          setState(() => _busy = true);
                          await app.markDisease(diseaseId: id);
                          if (!mounted) return;
                          setState(() => _busy = false);
                          if (!context.mounted) return;
                          showMessage(context, '记下了');
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Text(already ? '已记' : '记下'),
                ),
              ),
            ),
    );
  }

  String _oneLine(String raw) {
    final sentence = raw.trim().split('。').first.trim();
    if (sentence.isEmpty) return '';
    return sentence.endsWith('。') ? sentence : '$sentence。';
  }
}

class DiseaseDetailPage extends StatelessWidget {
  const DiseaseDetailPage({required this.diseaseId, super.key});

  final String diseaseId;

  @override
  Widget build(BuildContext context) {
    final disease = diseaseById(diseaseId);
    if (disease == null) {
      final title = diseaseId.trim().isEmpty ? '看病' : diseaseId;
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: zhuajiBar(title),
        body: Center(child: Text(diseaseId.trim().isEmpty ? '没有' : '这是你手写的名字')),
      );
    }
    return DiseaseLibraryPage(initialId: diseaseId);
  }
}
