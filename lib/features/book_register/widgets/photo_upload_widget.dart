import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

class PhotoUploadWidget extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxPhotos;
  const PhotoUploadWidget({super.key, required this.photos, required this.onAdd, required this.onRemove, this.maxPhotos = 5});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
      if (photos.length < maxPhotos) GestureDetector(onTap: onAdd, child: Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), border: Border.all(color: AppColors.primary)),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: AppColors.primary), Text('촬영', style: TextStyle(fontSize: 12, color: AppColors.primary))]))),
      ...photos.asMap().entries.map((e) => Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
        child: Stack(children: [const Center(child: Icon(Icons.image)), Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => onRemove(e.key),
          child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white))))]))),
    ]));
  }
}
