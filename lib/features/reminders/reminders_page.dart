import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/reminders/reminder_planner.dart';
import '../../state/app_controller.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final items = app.upcoming;
    return Scaffold(
      appBar: AppBar(title: const Text('提醒')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            '疫苗、驱虫、喂食、换粮、保质期和开封倒计时都会排进本地通知。系统可能会把非精确提醒稍晚一点送到。',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: app.enableNotifications,
            child: const Text('开启通知权限'),
          ),
          if (app.permissionNote != null) ...[
            const SizedBox(height: 8),
            Text(
              app.permissionNote!,
              style: const TextStyle(color: AppColors.olive, height: 1.4),
            ),
          ],
          const SizedBox(height: Space.x4),
          if (items.isEmpty)
            const EmptyHint(title: '近期没有提醒', body: '记下下次疫苗、驱虫或一袋粮的保质期后，这里会出现。')
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SoftCard(
                  child: InkWell(
                    onTap: () {
                      switch (item.channel) {
                        case ReminderChannel.health:
                          context.go('/health');
                        case ReminderChannel.feeding:
                          context.push('/feeding');
                        case ReminderChannel.food:
                          context.go('/pantry');
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_icon(item.channel), color: AppColors.olive),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.body,
                                style: const TextStyle(height: 1.35),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${formatDate(item.when)} ${formatClock(item.when.hour, item.when.minute)}'
                                '${item.repeatsDaily ? ' · 每天' : ''}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: Space.x4),
          const DisclaimerBanner(),
        ],
      ),
    );
  }

  IconData _icon(ReminderChannel channel) => switch (channel) {
    ReminderChannel.health => Icons.favorite_border_rounded,
    ReminderChannel.feeding => Icons.restaurant_outlined,
    ReminderChannel.food => Icons.inventory_2_outlined,
  };
}
