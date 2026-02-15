import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/location_helper.dart';
import '../../../data/models/organization_model.dart';
import '../../../providers/donation_providers.dart';
import '../../../providers/location_providers.dart';
import '../../../providers/matching_providers.dart';
import '../../../providers/user_providers.dart';

class OrganizationListScreen extends ConsumerStatefulWidget {
  const OrganizationListScreen({super.key});
  @override
  ConsumerState<OrganizationListScreen> createState() => _OrganizationListScreenState();
}

class _OrganizationListScreenState extends ConsumerState<OrganizationListScreen> {
  String _categoryFilter = 'all';
  bool _showMap = false;
  GoogleMapController? _mapController;

  String _categoryLabel(String category) {
    switch (category) {
      case 'library': return '도서관';
      case 'school': return '학교';
      case 'ngo': return 'NGO';
      default: return category;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'library': return Icons.local_library;
      case 'school': return Icons.school;
      case 'ngo': return Icons.volunteer_activism;
      default: return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRegion = ref.watch(selectedRegionProvider);
    final orgsAsync = selectedRegion != null
        ? ref.watch(organizationsByRegionProvider)
        : ref.watch(organizationsProvider);
    final matchesAsync = ref.watch(wishBookMatchesProvider);
    final userProfile = ref.watch(currentUserProfileProvider).valueOrNull;
    final positionAsync = ref.watch(currentPositionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기증 기관'),
        actions: [
          // 리스트/지도 토글
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
            tooltip: _showMap ? '목록 보기' : '지도 보기',
          ),
        ],
      ),
      body: Column(children: [
        // 지역 드롭다운 + 카테고리 필터
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD, vertical: 8),
          child: Column(children: [
            // 지역 드롭다운
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedRegion,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: '지역 필터',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('전체 지역')),
                    ...LocationHelper.koreanRegions.map((r) =>
                        DropdownMenuItem(value: r, child: Text(r))),
                  ],
                  onChanged: (v) => ref.read(selectedRegionProvider.notifier).state = v,
                ),
              ),
              // 고향 칩
              if (userProfile?.hometownRegion != null) ...[
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.home, size: 16),
                  label: Text('고향 (${userProfile!.hometownRegion})'),
                  onPressed: () {
                    ref.read(selectedRegionProvider.notifier).state = userProfile.hometownRegion;
                  },
                ),
              ],
            ]),
            const SizedBox(height: 8),
            // 카테고리 필터
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _FilterChip(label: '전체', selected: _categoryFilter == 'all', onTap: () => setState(() => _categoryFilter = 'all')),
                const SizedBox(width: 8),
                _FilterChip(label: '도서관', selected: _categoryFilter == 'library', onTap: () => setState(() => _categoryFilter = 'library')),
                const SizedBox(width: 8),
                _FilterChip(label: '학교', selected: _categoryFilter == 'school', onTap: () => setState(() => _categoryFilter = 'school')),
                const SizedBox(width: 8),
                _FilterChip(label: 'NGO', selected: _categoryFilter == 'ngo', onTap: () => setState(() => _categoryFilter = 'ngo')),
              ]),
            ),
          ]),
        ),

        // 희망도서 매칭 배너
        matchesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (matches) {
            if (matches.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.success.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${matches.length}개 매칭! 내 책과 희망도서가 일치하는 기관이 있어요',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            );
          },
        ),

        // 본문: 리스트 또는 지도
        Expanded(child: orgsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
          data: (orgs) {
            final filtered = _categoryFilter == 'all' ? orgs : orgs.where((o) => o.category == _categoryFilter).toList();
            if (_showMap) {
              return _buildMapView(filtered, positionAsync);
            }
            return _buildListView(filtered, positionAsync);
          },
        )),
      ]),
    );
  }

  Widget _buildListView(List<OrganizationModel> orgs, AsyncValue positionAsync) {
    if (orgs.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.business_outlined, size: 64, color: AppColors.divider),
        const SizedBox(height: 16),
        Text('등록된 기관이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: orgs.length,
      itemBuilder: (_, i) {
        final org = orgs[i];
        // 거리 계산
        String? distanceText;
        final pos = positionAsync.valueOrNull;
        if (pos != null && org.geoPoint != null) {
          final meters = ref.read(locationServiceProvider).calculateDistance(
            pos.latitude, pos.longitude,
            org.geoPoint!.latitude, org.geoPoint!.longitude,
          );
          distanceText = LocationHelper.formatDistance(meters);
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(AppRoutes.donationPath(org.id)),
            child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(_categoryIcon(org.category), color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(org.name, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(org.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(_categoryLabel(org.category), style: AppTypography.caption.copyWith(color: Colors.blue)),
                  ),
                  if (org.region != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text('${org.region}', style: AppTypography.caption.copyWith(color: AppColors.success)),
                    ),
                  ],
                  if (distanceText != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(distanceText, style: AppTypography.caption.copyWith(color: AppColors.warning)),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(child: Text(org.address, style: AppTypography.caption, overflow: TextOverflow.ellipsis)),
                ]),
                if (org.wishBooks.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(spacing: 4, children: org.wishBooks.take(3).map((g) => Chip(
                    label: Text(g, style: const TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList()),
                ],
              ])),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ])),
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<OrganizationModel> orgs, AsyncValue positionAsync) {
    final orgsWithGeo = orgs.where((o) => o.geoPoint != null).toList();
    final pos = positionAsync.valueOrNull;
    final initialPos = pos != null
        ? LatLng(pos.latitude, pos.longitude)
        : const LatLng(37.5665, 126.978); // 서울 기본

    final markers = orgsWithGeo.map((org) {
      return Marker(
        markerId: MarkerId(org.id),
        position: LatLng(org.geoPoint!.latitude, org.geoPoint!.longitude),
        infoWindow: InfoWindow(
          title: org.name,
          snippet: org.address,
          onTap: () => context.push(AppRoutes.donationPath(org.id)),
        ),
      );
    }).toSet();

    if (orgsWithGeo.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.map_outlined, size: 64, color: AppColors.divider),
        const SizedBox(height: 16),
        Text('위치 정보가 있는 기관이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _showMap = false),
          child: const Text('목록으로 보기'),
        ),
      ]));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.blue : AppColors.divider),
        ),
        child: Text(label, style: AppTypography.bodySmall.copyWith(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }
}
