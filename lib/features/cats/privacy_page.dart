import 'package:flutter/material.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';

/// Same text as docs/privacy-policy.md; keep the two in step.
const privacySections = [
  (
    title: '存在哪里',
    body:
        '猫咪资料、喂养和健康记录、粮仓、化验单和照片默认只存在这台手机里，没有账号。'
        '只有你自己配置了同步服务，记录才会同步到你指定的服务器。卸载应用会一起删掉本机数据。',
  ),
  (
    title: '相机和相册',
    body:
        '只在你点「扫粮」、拍包装、拍化验单或给猫拍照时使用。'
        '扫码、认包装和认化验单都在手机上完成，照片不上传。',
  ),
  (title: '通知', body: '用来提醒疫苗、驱虫、体检和粮食到期。点通知上的「已完成」只会在手机里记一笔。'),
  (
    title: '蓝牙',
    body:
        '只在你打开「蓝牙秤」时使用，用来读取体重秤广播的体重数字'
        '（支持小米体脂秤 2 和标准蓝牙体重秤）。'
        '不用蓝牙定位，不记录附近的其他设备，不连接秤以外的设备。'
        'Android 11 及更早的系统要求蓝牙扫描时给「位置」权限，'
        '爪记不会读取或保存你的位置。',
  ),
  (title: '你自己的体重', body: '「抱猫称」会记住你上次自己的体重，下次直接带出，只存在这台手机里，随时可以重称覆盖。'),
  (title: '联系', body: '这是个人维护的原型应用。对隐私有疑问，可以在项目仓库里留言。'),
];

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('隐私政策'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            '爪记 2.7 · 2026 年 10 月更新',
            style: zhuaji.copyWith(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          for (final section in privacySections) ...[
            QuietCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: zhuaji.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    section.body,
                    style: zhuaji.copyWith(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
