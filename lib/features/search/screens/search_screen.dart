import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/book_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _recentSearches = ['클린 코드', '어린왕자', '데미안', '1984'];
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _doSearch(String query) {
    setState(() => _query = query.trim());
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _doSearch('');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _doSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '책 제목, 저자로 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _doSearch('');
                        },
                      )
                    : null,
              ),
              onSubmitted: _doSearch,
              onChanged: _onSearchChanged,
            ),
          ),
          if (_query.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최근 검색어', style: AppTypography.titleMedium),
                  TextButton(
                    onPressed: () => setState(() => _recentSearches.clear()),
                    child: Text(
                      '전체 삭제',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _recentSearches.isEmpty
                  ? Center(
                      child: Text(
                        '최근 검색어가 없습니다',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recentSearches.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: AppColors.textSecondary,
                        ),
                        title: Text(_recentSearches[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(
                            () => _recentSearches.removeAt(index),
                          ),
                        ),
                        onTap: () {
                          _searchController.text = _recentSearches[index];
                          _doSearch(_recentSearches[index]);
                        },
                      ),
                    ),
            ),
          ] else
            Expanded(
              child: ref.watch(bookSearchProvider(_query)).when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppDimensions.paddingSM),
                          Text(
                            '검색 중 오류가 발생했습니다',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingSM),
                          TextButton(
                            onPressed: () => ref.invalidate(
                              bookSearchProvider(_query),
                            ),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),
                    data: (books) {
                      if (books.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppDimensions.paddingSM),
                              Text(
                                '\'$_query\'에 대한 검색 결과가 없습니다',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMD,
                        ),
                        itemCount: books.length,
                        itemBuilder: (_, i) {
                          final book = books[i];
                          return ListTile(
                            leading: Container(
                              width: 45,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                                borderRadius: BorderRadius.circular(4),
                                image: book.coverImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          book.coverImageUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: book.coverImageUrl == null
                                  ? const Icon(
                                      Icons.book,
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    )
                                  : null,
                            ),
                            title: Text(
                              book.title,
                              style: AppTypography.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              book.author,
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              book.location,
                              style: AppTypography.caption,
                            ),
                            onTap: () => context.push(
                              AppRoutes.bookDetailPath(book.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
        ],
      ),
    );
  }
}
