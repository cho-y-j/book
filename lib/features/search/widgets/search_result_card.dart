import 'package:flutter/material.dart';
import '../../home/widgets/book_feed_card.dart';

class SearchResultCard extends StatelessWidget {
  final VoidCallback? onTap;
  const SearchResultCard({super.key, this.onTap});
  @override
  Widget build(BuildContext context) => BookFeedCard(onTap: onTap);
}
