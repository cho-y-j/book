import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/datasources/remote/book_api_datasource.dart';

final _bookTitleSearchProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final datasource = BookApiDatasource();
  return datasource.searchByTitle(query.trim());
});

class BookTitleSearchScreen extends ConsumerStatefulWidget {
  const BookTitleSearchScreen({super.key});
  @override
  ConsumerState<BookTitleSearchScreen> createState() => _BookTitleSearchScreenState();
}

class _BookTitleSearchScreenState extends ConsumerState<BookTitleSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = _query.isNotEmpty ? ref.watch(_bookTitleSearchProvider(_query)) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('책 검색 등록')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '책 제목 또는 저자를 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text('등록할 책을 검색해보세요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : searchResult!.when(
                    data: (books) {
                      if (books.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: 16),
                              Text('"$_query" 검색 결과가 없습니다', style: AppTypography.bodyLarge),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () => context.push(AppRoutes.manualRegister),
                                child: const Text('직접 등록하기'),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                        itemCount: books.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return _BookSearchResultTile(
                            title: book['title'] ?? '',
                            author: book['author'] ?? '',
                            publisher: book['publisher'] ?? '',
                            coverUrl: book['cover'] ?? '',
                            isbn13: book['isbn13'] ?? '',
                            onTap: () {
                              // TODO: 선택한 책 정보를 book_condition 화면으로 전달
                              context.push(AppRoutes.bookCondition, extra: book);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text('검색 중 오류가 발생했습니다', style: AppTypography.bodyLarge),
                          const SizedBox(height: 8),
                          TextButton(onPressed: () => setState(() {}), child: const Text('다시 시도')),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookSearchResultTile extends StatelessWidget {
  final String title;
  final String author;
  final String publisher;
  final String coverUrl;
  final String isbn13;
  final VoidCallback onTap;

  const _BookSearchResultTile({
    required this.title,
    required this.author,
    required this.publisher,
    required this.coverUrl,
    required this.isbn13,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: coverUrl.isNotEmpty
            ? Image.network(coverUrl, width: 50, height: 70, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 50, height: 70, color: AppColors.divider,
                  child: Icon(Icons.book, color: AppColors.textSecondary),
                ))
            : Container(
                width: 50, height: 70, color: AppColors.divider,
                child: Icon(Icons.book, color: AppColors.textSecondary),
              ),
      ),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.titleSmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(author, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall),
          Text(publisher, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
