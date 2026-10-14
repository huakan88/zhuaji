import 'package:flutter/material.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/disease_catalog.dart';
import '../../state/app_controller.dart';

class DiseaseLibraryPage extends StatefulWidget {
  const DiseaseLibraryPage({this.initialId, super.key});

  final String? initialId;

  @override
  State<DiseaseLibraryPage> createState() => _DiseaseLibraryPageState();
}

class _DiseaseLibraryPageState extends State<DiseaseLibraryPage> {
  String? _selected;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final marked = <String>{
      for (final item in app.catConditions) item.diseaseId,
    };
    final selectedId =
        _selected ??
        widget.initialId ??
        (marked.isEmpty ? diseaseCatalog.first.id : marked.first);
    final disease = diseaseById(selectedId) ?? diseaseCatalog.first;
    final already = cat == null ? false : app.conditionFor(disease.id) != null;
    final flag = disease.redFlags.isEmpty ? '' : disease.redFlags.first;
    final diet = _oneLine(disease.diet);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('看病'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in diseaseCatalog)
                ChoiceChip(
                  label: Text(item.name),
                  selected: item.id == disease.id,
                  selectedColor: AppColors.coral,
                  onSelected: (_) => setState(() => _selected = item.id),
                ),
            ],
          ),
          const SizedBox(height: 16),
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
      ),
      bottomNavigationBar: cat == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: already || _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          await app.markDisease(diseaseId: disease.id);
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
      return Scaffold(
        appBar: zhuajiBar('看病'),
        body: const Center(child: Text('没有')),
      );
    }
    return DiseaseLibraryPage(initialId: diseaseId);
  }
}
