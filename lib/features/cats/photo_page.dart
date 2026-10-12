import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../services/photo_store.dart';
import '../../state/app_controller.dart';

class PhotoPage extends StatelessWidget {
  const PhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final photos = app.photos;
    if (cat == null) {
      return const Scaffold(body: Center(child: Text('先选择一只猫')));
    }
    final oldest = photos.isEmpty ? null : photos.first;
    final newest = photos.length < 2 ? null : photos.last;
    return Scaffold(
      appBar: AppBar(title: Text('${cat.name}的体态')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            '隔一段时间拍一张，方便自己看体态变化。照片只存在这台手机上。',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: Space.x4),
          if (oldest != null && newest != null)
            Row(
              children: [
                Expanded(child: _shot('较早', oldest.path, oldest.takenAt, oldest.weightKg)),
                const SizedBox(width: 12),
                Expanded(child: _shot('最近', newest.path, newest.takenAt, newest.weightKg)),
              ],
            )
          else
            const SoftCard(
              child: Text('两张以上的照片才会并排对比。'),
            ),
          const SizedBox(height: Space.x4),
          FilledButton(
            onPressed: () => _add(context, app),
            child: const Text('再拍一张'),
          ),
          const SizedBox(height: Space.x4),
          for (final photo in photos.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.m),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: CatImage(path: photo.path),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(formatDate(photo.takenAt), style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${photo.weightKg == null ? '' : '${photo.weightKg!.toStringAsFixed(2)} kg · '}${photo.note}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => app.removePhoto(photo.id),
                        child: const Text('删除'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shot(String label, String path, DateTime at, double? weight) {
    return SoftCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.m),
            child: AspectRatio(aspectRatio: 1, child: CatImage(path: path)),
          ),
          const SizedBox(height: 8),
          Text(formatDate(at), style: const TextStyle(fontSize: 12)),
          if (weight != null)
            Text('${weight.toStringAsFixed(2)} kg', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, AppController app) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (file == null) return;
    final stored = await PhotoStore().persist(file.path);
    await app.addPhoto(path: stored, weightKg: app.latestWeight?.weightKg, note: '体态记录');
  }
}
