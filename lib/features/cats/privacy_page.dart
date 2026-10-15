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
        '只在你打开今天或粮仓里的相机、拍包装、拍化验单、拍疫苗贴纸或给猫拍照时使用。'
        '扫码、认包装、认化验单和认贴纸都在手机上完成，照片不上传。',
  ),
  (
    title: '条码查询',
    body:
        '扫到 EAN 或 UPC 时，会把这串数字发给公开商品库'
        '（Open Pet Food Facts、Open Food Facts、Open Products Facts、'
        'ProductGuru、UPCitemdb）查询品牌、名称、规格、配料和成分。'
        '查到的结果存在这台手机里。照片和猫咪资料不会一起发出去。'
        '这些免密钥的库经常没有国产粮。构建时如果填了聚合数据、阿里云市场、'
        '顶想云、Go-UPC 或 EAN-Search 的密钥，条码数字也会发给对应服务；'
        '没有密钥就不会请求它们。查不到时可以拍包装或点选品牌，记在手机里。',
  ),
  (title: '通知', body: '用来提醒疫苗、驱虫、体检、粮食到期和补货。点通知上的「已完成」只会在手机里记一笔。'),
  (
    title: '桌面小组件',
    body:
        'Android 可以加「今天的事」。iPhone 要等安装包里带上小组件之后才能加。'
        '上面是今天要办的，下面是下一个提醒，点一下打开对应的页。'
        '只在你添加小组件时出现在桌面。日历页可以改成不显示待办。不上传。',
  ),
  (
    title: '蓝牙',
    body:
        '只在你打开「蓝牙秤」时使用，用来读取体重秤广播的体重数字'
        '（支持小米体脂秤 2 和标准蓝牙体重秤）。'
        '不用蓝牙定位，不记录附近的其他设备，不连接秤以外的设备。'
        'Android 11 及更早的系统要求蓝牙扫描时给「位置」权限，'
        '肉垫本不会读取或保存你的位置。',
  ),
  (title: '你自己的体重', body: '「抱猫称」会记住你上次自己的体重，下次直接带出，只存在这台手机里，随时可以重称覆盖。'),
  (title: '联系', body: '这是个人维护的原型应用。对隐私有疑问，可以在项目仓库里留言。'),
];

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('隐私政策'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            '肉垫本 PawPad · 2.13.0 · 2026 年 10 月更新',
            style: zhuaji.copyWith(
              fontSize: 13,
              color: AppColors.of(context).muted,
            ),
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
