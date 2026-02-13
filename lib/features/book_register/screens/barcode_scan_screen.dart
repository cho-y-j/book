import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});
  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('바코드 스캔'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      backgroundColor: Colors.black,
      body: Stack(children: [
        Center(child: Container(
          width: 280, height: 180,
          decoration: BoxDecoration(border: Border.all(color: AppColors.accent, width: 2), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
          child: _isScanning
              ? const Center(child: Text('카메라 영역\n(바코드를 스캔해주세요)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)))
              : const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        )),
        Positioned(bottom: 40, left: 0, right: 0, child: Column(children: [
          Text('ISBN 바코드를 사각형 안에 맞춰주세요', style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('직접 ISBN 입력', style: TextStyle(color: AppColors.accent)),
          ),
        ])),
      ]),
    );
  }
}
