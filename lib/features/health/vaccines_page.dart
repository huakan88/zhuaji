import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';
import 'known_or_custom.dart';

class VaccinesPage extends StatefulWidget {
  const VaccinesPage({super.key});

  @override
  State<VaccinesPage> createState() => _VaccinesPageState();
}

class _VaccinesPageState extends State<VaccinesPage> {
  static const _names = ['猫三联', '狂犬'];
  final _customText = TextEditingController();
  var _name = '猫三联';
  var _custom = false;
  DateTime? _given;
  var _busy = false;

  @override
  void dispose() {
    _customText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: zhuajiBar('疫苗'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final given = _given ??= dateOnly(app.now);
    final next = nextVaccineDate(cat.birthday, given);
    final shots = [...app.catVaccines]
      ..sort((a, b) {
        final left = a.nextDue ?? a.givenOn;
        final right = b.nextDue ?? b.givenOn;
        return left.compareTo(right);
      });
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('疫苗'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          if (shots.isEmpty)
            Text(
              '还没记疫苗',
              style: zhuaji.copyWith(color: AppColors.of(context).muted),
            )
          else
            for (final shot in shots.take(3)) _Record(shot: shot),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/sticker'),
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: const Text('拍贴纸'),
          ),
          const SizedBox(height: 16),
          const SectionLabel('记一针'),
          const SizedBox(height: 8),
          QuietCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KnownOrCustom(
                  known: _names,
                  selected: _name,
                  custom: _custom,
                  controller: _customText,
                  hint: '疫苗名称',
                  onKnown: (label) => setState(() {
                    _custom = false;
                    _name = label;
                  }),
                  onCustom: () => setState(() => _custom = true),
                ),
                DateChips(
                  label: '接种',
                  date: given,
                  today: app.now,
                  onChanged: (value) => setState(() => _given = value),
                ),
                Text(
                  '下次 ${formatDate(next)}',
                  style: zhuaji.copyWith(
                    fontSize: 13,
                    color: AppColors.of(context).muted,
                  ),
                ),
              ],
            ),
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
                    final name = chosenOrTyped(
                      custom: _custom,
                      controller: _customText,
                      selected: _name,
                    );
                    if (name == null) {
                      showMessage(context, '先写上疫苗名称');
                      return;
                    }
                    setState(() => _busy = true);
                    await app.saveVaccine(
                      VaccineDraft(
                        catId: cat.id,
                        name: name,
                        givenOn: given,
                        nextDue: next,
                      ),
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (!context.mounted) return;
                    showMessage(context, '记下了');
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
}

class _Record extends StatelessWidget {
  const _Record({required this.shot});

  final VaccineRecord shot;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final due = shot.nextDue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: QuietCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            const IconWell(icon: Icons.vaccines_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: zhuaji.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    due == null ? '下次还没定' : '下次 ${countdownOf(due, app.now)}',
                    style: zhuaji.copyWith(
                      color: AppColors.of(context).muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final next = await app.completeVaccine(shot);
                if (!context.mounted) return;
                showUndo(
                  context,
                  '下次 ${formatDate(next)}',
                  () => app.restoreVaccine(shot),
                );
              },
              child: const Text('完成'),
            ),
            TextButton(
              onPressed: () async {
                if (!await confirmDelete(context, '删掉这针？')) return;
                await app.removeVaccine(shot.id);
              },
              child: const Text('删除'),
            ),
          ],
        ),
      ),
    );
  }
}
