import 'package:flutter/material.dart';
import '../../../core/constants/enums.dart';
import '../../common/widgets/genre_chip.dart';

class CategoryFilterChips extends StatelessWidget {
  final String selectedGenre;
  final ValueChanged<String> onGenreSelected;
  const CategoryFilterChips({super.key, required this.selectedGenre, required this.onGenreSelected});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children:
      BookGenre.values.map((g) => Padding(padding: const EdgeInsets.only(right: 8), child: GenreChip(genre: g.label, selected: g.label == selectedGenre, onTap: () => onGenreSelected(g.label)))).toList(),
    ));
  }
}
