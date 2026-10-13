import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/paw_icon.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    if (app.cats.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.x6),
            child: EmptyHint(
              title: '家里还没有猫',
              body: '拍一张，起个名字，今天就能开始记。',
              action: '添加第一只猫',
              onAction: () => context.push('/cat-form'),
            ),
          ),
        ),
      );
    }
    final cat = app.active!;
    final alerts = _alerts(app);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HomeHeader(app: app, cat: cat),
              const SizedBox(height: 18),
              Text(
                '要留心的',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (alerts.isEmpty)
                const _QuietDay()
              else
                for (final alert in alerts) _AlertTile(alert: alert),
              const Spacer(),
              const _ScanNudge(),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push('/scan'),
                child: const Text('扫条码'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Alert> _alerts(AppController app) {
    final items = <_Alert>[];
    final weight = weightChangeOverMonth(app.catWeights);
    if (weight != null && weight.notable) {
      final direction = weight.percent > 0 ? '增加' : '下降';
      final hint = weight.percent > 0 ? '留意食量' : '留意食欲';
      final percent = (weight.percent.abs() * 100).toStringAsFixed(0);
      items.add(
        _Alert(
          icon: Icons.monitor_weight_outlined,
          title: '体重变化',
          detail: '近 ${weight.days} 天体重$direction了 $percent%，$hint。',
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final deworm = app.nextExternal?.nextDue ?? app.nextInternal?.nextDue;
    if (deworm != null && calendarDays(app.now, deworm) <= 14) {
      items.add(
        _Alert(
          icon: Icons.medication_outlined,
          title: '驱虫',
          detail: formatMonthDay(deworm),
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final vaccine = app.nextVaccine?.nextDue;
    if (vaccine != null && calendarDays(app.now, vaccine) <= 30) {
      items.add(
        _Alert(
          icon: Icons.vaccines_outlined,
          title: '下次疫苗',
          detail: app.nextVaccine?.name ?? formatMonthDay(vaccine),
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final expiry = app.nearestExpiry?.item.expiryDate;
    if (expiry != null && calendarDays(app.now, expiry) <= 30) {
      final days = calendarDays(app.now, expiry);
      items.add(
        _Alert(
          icon: Icons.kitchen_outlined,
          title: '临期猫粮',
          detail: days <= 0 ? '今天到期' : '还剩 $days 天',
          onTap: (context) => context.push('/pantry'),
        ),
      );
    }
    return items;
  }
}

int calendarDays(DateTime from, DateTime to) {
  final start = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);
  return end.difference(start).inDays;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.app, required this.cat});

  final AppController app;
  final CatProfile cat;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: Radii.xl,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: softShadow,
                ),
                child: CatAvatar(
                  path: cat.avatarPath,
                  size: 64,
                  selected: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CatMenu(app: app, cat: cat),
              ),
            ],
          ),
          if (app.cats.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final item in app.cats)
                    if (item.id != cat.id)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => app.selectCat(item.id),
                          child: CatAvatar(
                            path: item.avatarPath,
                            size: 40,
                            ring: ringPalette[item.id % ringPalette.length],
                          ),
                        ),
                      ),
                  GestureDetector(
                    onTap: () => context.push('/cat-form'),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_rounded, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuietDay extends StatelessWidget {
  const _QuietDay();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: Radii.xl,
      color: AppColors.tintGreen,
      child: Row(
        children: [
          const PawIcon(size: 36, color: AppColors.sage),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('今天很安静\n没有要办的事，去陪它一会儿。', style: TextStyle(height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _ScanNudge extends StatelessWidget {
  const _ScanNudge();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/cats/cat-icon.jpg',
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            '对着包装扫一下，日期我来记。',
            style: TextStyle(color: AppColors.muted, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _Alert {
  const _Alert({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final void Function(BuildContext context) onTap;
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final _Alert alert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        radius: Radii.xl,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: InkWell(
          onTap: () => alert.onTap(context),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tintCoral,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(alert.icon, color: AppColors.coralDeep, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.detail,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatMenu extends StatelessWidget {
  const _CatMenu({required this.app, required this.cat});

  final AppController app;
  final CatProfile cat;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      onSelected: (id) {
        if (id == -1) {
          context.push('/cat-form');
          return;
        }
        app.selectCat(id);
      },
      itemBuilder: (context) => [
        for (final item in app.cats)
          PopupMenuItem(value: item.id, child: Text(item.name)),
        const PopupMenuItem(value: -1, child: Text('添加猫咪')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greetingFor(app.now),
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  cat.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
          Text(
            ageLabel(cat.birthday, app.now),
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
