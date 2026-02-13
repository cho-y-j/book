import 'package:flutter/material.dart';
import '../../../app/theme/app_dimensions.dart';
import 'book_feed_card.dart';

class BookFeedList extends StatelessWidget {
  final int itemCount;
  const BookFeedList({super.key, this.itemCount = 10});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(padding: const EdgeInsets.all(AppDimensions.paddingMD), itemCount: itemCount, itemBuilder: (_, i) => const Padding(padding: EdgeInsets.only(bottom: 8), child: BookFeedCard()));
  }
}
