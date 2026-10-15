import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';

/// Camera that opens the barcode scanner. Used on 今天 and 粮仓.
class ScanCameraButton extends StatelessWidget {
  const ScanCameraButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '扫码',
      onPressed: () => context.push('/scan'),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.of(context).brand,
        foregroundColor: AppColors.of(context).onBrand,
        fixedSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.m),
        ),
      ),
      icon: const Icon(Icons.photo_camera_outlined, size: 22),
    );
  }
}
