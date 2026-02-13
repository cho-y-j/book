import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating; final double size; final ValueChanged<double>? onRatingChanged;
  const StarRatingWidget({super.key, required this.rating, this.size = 24, this.onRatingChanged});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => GestureDetector(
      onTap: onRatingChanged != null ? () => onRatingChanged!(i + 1.0) : null,
      child: Icon(i < rating.floor() ? Icons.star : (i < rating ? Icons.star_half : Icons.star_border), color: AppColors.warning, size: size))));
  }
}
