import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/haptics.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/care_timeline.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/care_story.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final kg = app.latestWeight?.weightKg;
    final events = cat == null
        ? const <CareEvent>[]
        : recentCare(
            catId: cat.id,
            vaccines: app.vaccines,
            deworms: app.deworms,
            visits: app.visits,
            checkups: app.checkups,
            weights: app.weights,
            now: app.now,
          );
    const tiles = [
      _Tile('体重', '步进记下', Icons.monitor_weight_outlined, '/weight'),
      _Tile('疫苗', '猫三联、狂犬', Icons.vaccines_outlined, '/vaccines'),
      _Tile('驱虫', '体内、体外', Icons.bug_report_outlined, '/deworms'),
      _Tile('就医', '体检、呕吐', Icons.local_hospital_outlined, '/visits'),
      _Tile('体检', '按年龄', Icons.fact_check_outlined, '/checkups'),
      _Tile('看病', '点病名', Icons.healing_outlined, '/diseases'),
      _Tile('化验', '血常规、生化', Icons.biotech_outlined, '/labs'),
    ];
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('健康'),
      body: FadeIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 108),
          children: [
            if (cat != null) ...[
              Row(
                children: [
                  CatAvatar(path: cat.avatarPath, size: 56, selected: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: zhuaji.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _meta(cat, app.now),
                          style: zhuaji.copyWith(
                            fontSize: 12,
                            color: AppColors.of(context).muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kg != null)
                    Text(
                      '${kg.toStringAsFixed(2)} kg',
                      style: zhuaji.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: _Quick(
                    label: '记体重',
                    icon: Icons.monitor_weight_outlined,
                    onTap: () {
                      pawTap();
                      context.push('/weight');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Quick(
                    label: '记疫苗',
                    icon: Icons.vaccines_outlined,
                    onTap: () {
                      pawTap();
                      context.push('/vaccines');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Quick(
                    label: '记驱虫',
                    icon: Icons.bug_report_outlined,
                    onTap: () {
                      pawTap();
                      context.push('/deworms');
                    },
                  ),
                ),
              ],
            ),
            if (cat != null &&
                (app.lastDeworm != null || app.lastVaccine != null)) ...[
              const SizedBox(height: 8),
              if (app.lastDeworm != null)
                _RepeatDeworm(last: app.lastDeworm!, catId: cat.id),
              if (app.lastDeworm != null && app.lastVaccine != null)
                const SizedBox(height: 8),
              if (app.lastVaccine != null)
                _RepeatVaccine(last: app.lastVaccine!, catId: cat.id),
            ],
            const SizedBox(height: 16),
            const SectionLabel('近来'),
            const SizedBox(height: 8),
            CareTimeline(events: events, empty: '疫苗和驱虫会排在这里'),
            const SizedBox(height: 16),
            const SectionLabel('护理'),
            const SizedBox(height: 8),
            QuietCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
                childAspectRatio: 0.92,
                children: [
                  for (final tile in tiles)
                    InkWell(
                      onTap: () => context.push(tile.path),
                      borderRadius: BorderRadius.circular(Radii.m),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconWell(icon: tile.icon),
                          const SizedBox(height: 8),
                          Text(
                            tile.label,
                            style: zhuaji.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tile.caption,
                            textAlign: TextAlign.center,
                            style: zhuaji.copyWith(
                              fontSize: 11,
                              color: AppColors.of(context).muted,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _meta(CatProfile cat, DateTime now) {
    final parts = <String>[
      if (cat.breed != null && cat.breed!.isNotEmpty) cat.breed!,
      ageLabel(cat.birthday, now),
    ];
    return parts.join(' · ');
  }
}

class _Quick extends StatelessWidget {
  const _Quick({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.of(context).brandTint,
        foregroundColor: AppColors.of(context).ink,
        minimumSize: const Size.fromHeight(72),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        side: BorderSide(color: AppColors.of(context).line),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Tile {
  const _Tile(this.label, this.caption, this.icon, this.path);

  final String label;
  final String caption;
  final IconData icon;
  final String path;
}

/// One tap records another dose of the last product. No new form.
class _RepeatDeworm extends StatefulWidget {
  const _RepeatDeworm({required this.last, required this.catId});

  final DewormRecord last;
  final int catId;

  @override
  State<_RepeatDeworm> createState() => _RepeatDewormState();
}

class _RepeatDewormState extends State<_RepeatDeworm> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    return OutlinedButton(
      onPressed: _busy
          ? null
          : () async {
              pawTap();
              setState(() => _busy = true);
              final given = dateOnly(app.now);
              await app.saveDeworm(
                DewormDraft(
                  catId: widget.catId,
                  kind: widget.last.kind,
                  product: widget.last.product,
                  givenOn: given,
                  nextDue: given.add(const Duration(days: 90)),
                ),
              );
              if (!mounted) return;
              setState(() => _busy = false);
              if (!context.mounted) return;
              showMessage(context, '记下了');
            },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.of(context).ink,
        side: BorderSide(color: AppColors.of(context).line),
      ),
      child: Text('再记 ${widget.last.product}'),
    );
  }
}

/// One tap records another dose of the last vaccine. No new form.
class _RepeatVaccine extends StatefulWidget {
  const _RepeatVaccine({required this.last, required this.catId});

  final VaccineRecord last;
  final int catId;

  @override
  State<_RepeatVaccine> createState() => _RepeatVaccineState();
}

class _RepeatVaccineState extends State<_RepeatVaccine> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    return OutlinedButton(
      onPressed: _busy
          ? null
          : () async {
              pawTap();
              setState(() => _busy = true);
              final given = dateOnly(app.now);
              await app.saveVaccine(
                VaccineDraft(
                  catId: widget.catId,
                  name: widget.last.name,
                  givenOn: given,
                  nextDue: nextVaccineDate(
                    app.catById(widget.catId)?.birthday,
                    given,
                  ),
                ),
              );
              if (!mounted) return;
              setState(() => _busy = false);
              if (!context.mounted) return;
              showMessage(context, '记下了');
            },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.of(context).ink,
        side: BorderSide(color: AppColors.of(context).line),
      ),
      child: Text('再记 ${widget.last.name}'),
    );
  }
}
