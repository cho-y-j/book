import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/app/theme/app_theme.dart';
import 'package:book_bridge/app/theme/app_typography.dart';
import 'package:book_bridge/app/theme/app_dimensions.dart';
import 'package:book_bridge/features/common/widgets/empty_state_widget.dart';
import 'package:book_bridge/features/common/widgets/loading_widget.dart';
import 'package:book_bridge/features/common/widgets/genre_chip.dart';
import 'package:book_bridge/features/common/widgets/location_badge.dart';
import 'package:book_bridge/features/review/widgets/star_rating_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('아이콘, 타이틀, 서브타이틀 렌더링', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EmptyStateWidget(icon: Icons.book, title: '텅 비었어요', subtitle: '책을 등록해보세요')),
      ));
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.text('텅 비었어요'), findsOneWidget);
      expect(find.text('책을 등록해보세요'), findsOneWidget);
    });

    testWidgets('액션 버튼 있으면 렌더링', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: EmptyStateWidget(icon: Icons.book, title: '비어있음', actionLabel: '추가하기', onAction: () {})),
      ));
      expect(find.text('추가하기'), findsOneWidget);
    });
  });

  group('LoadingWidget', () {
    testWidgets('CircularProgressIndicator 렌더링', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LoadingWidget()),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('GenreChip', () {
    testWidgets('장르 텍스트 렌더링', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: GenreChip(genre: '소설', selected: false, onTap: () {})),
      ));
      expect(find.text('소설'), findsOneWidget);
    });

    testWidgets('선택 상태 반영', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: GenreChip(genre: '소설', selected: true, onTap: () {})),
      ));
      expect(find.text('소설'), findsOneWidget);
    });
  });

  group('LocationBadge', () {
    testWidgets('위치 텍스트 렌더링', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LocationBadge(location: '서울시 강남구')),
      ));
      expect(find.text('서울시 강남구'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });
  });

  group('StarRatingWidget', () {
    testWidgets('별점 아이콘 렌더링', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StarRatingWidget(rating: 3.5)),
      ));
      expect(find.byIcon(Icons.star), findsWidgets);
    });
  });

  group('AppTheme', () {
    testWidgets('lightTheme 적용 가능', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Text('테마 테스트')),
      ));
      expect(find.text('테마 테스트'), findsOneWidget);
    });
  });

  group('AppTypography', () {
    test('모든 텍스트 스타일 정의됨', () {
      expect(AppTypography.headlineLarge, isA<TextStyle>());
      expect(AppTypography.headlineMedium, isA<TextStyle>());
      expect(AppTypography.headlineSmall, isA<TextStyle>());
      expect(AppTypography.titleLarge, isA<TextStyle>());
      expect(AppTypography.titleMedium, isA<TextStyle>());
      expect(AppTypography.titleSmall, isA<TextStyle>());
      expect(AppTypography.bodyLarge, isA<TextStyle>());
      expect(AppTypography.bodyMedium, isA<TextStyle>());
      expect(AppTypography.bodySmall, isA<TextStyle>());
      expect(AppTypography.labelLarge, isA<TextStyle>());
      expect(AppTypography.labelMedium, isA<TextStyle>());
      expect(AppTypography.caption, isA<TextStyle>());
    });
  });

  group('AppDimensions', () {
    test('패딩 값들이 양수', () {
      expect(AppDimensions.paddingSM, greaterThan(0));
      expect(AppDimensions.paddingMD, greaterThan(0));
      expect(AppDimensions.paddingLG, greaterThan(0));
      expect(AppDimensions.paddingXL, greaterThan(0));
    });

    test('radius 값들이 양수', () {
      expect(AppDimensions.radiusSM, greaterThan(0));
      expect(AppDimensions.radiusMD, greaterThan(0));
      expect(AppDimensions.radiusLG, greaterThan(0));
    });
  });
}
