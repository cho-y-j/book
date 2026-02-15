import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/location_helper.dart';
import '../../../data/models/organization_model.dart';
import '../../../providers/donation_providers.dart';
import '../../../providers/location_providers.dart';
import '../../../providers/user_providers.dart';

class PartnerRequestScreen extends ConsumerStatefulWidget {
  const PartnerRequestScreen({super.key});
  @override
  ConsumerState<PartnerRequestScreen> createState() => _PartnerRequestScreenState();
}

class _PartnerRequestScreenState extends ConsumerState<PartnerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  final _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isDetectingGps = false;

  String _partnerType = 'bookstore';
  String? _region;
  String? _subRegion;
  final Set<String> _selectedWishGenres = {};

  // 사업자등록증
  Uint8List? _licenseBytes;
  String? _licenseFileName;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickLicenseImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _licenseBytes = bytes;
          _licenseFileName = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 실패: $e')),
        );
      }
    }
  }

  Future<void> _detectGps() async {
    setState(() => _isDetectingGps = true);
    try {
      final locService = ref.read(locationServiceProvider);
      final position = await locService.getCurrentPosition();
      final address = await locService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _addressController.text = address['fullAddress'] ?? '';
        _region = address['region'];
        _subRegion = address['subRegion'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPS 감지 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetectingGps = false);
    }
  }

  void _onAddressChanged(String value) {
    _region = LocationHelper.extractRegion(value);
    _subRegion = LocationHelper.extractSubRegion(value);
  }

  Future<String?> _uploadLicense(String uid) async {
    if (_licenseBytes == null) return null;
    final ref = FirebaseStorage.instance
        .ref()
        .child('partners/$uid/business_license_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putData(_licenseBytes!, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_licenseBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사업자등록증을 첨부해주세요'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(currentUserProfileProvider).valueOrNull;
      if (user == null) throw Exception('로그인이 필요합니다');

      // 사업자등록증 업로드
      final licenseUrl = await _uploadLicense(user.uid);

      // 유저 업데이트: role=partner, dealerStatus=pending
      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'role': 'partner',
        'dealerStatus': 'pending',
        'dealerName': _nameController.text.trim(),
        'partnerType': _partnerType,
        'businessLicenseUrl': licenseUrl,
      });

      // 기부단체/도서관이면 Organization 문서 생성
      if (_partnerType == 'donationOrg' || _partnerType == 'library') {
        final org = OrganizationModel(
          id: '',
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          address: _addressController.text.trim(),
          contactPhone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          category: _partnerType == 'library' ? 'library' : 'ngo',
          isActive: false, // 관리자 승인 대기
          createdAt: DateTime.now(),
          geoPoint: _region != null ? const GeoPoint(0, 0) : null,
          wishBooks: _selectedWishGenres.toList(),
          region: _region,
          subRegion: _subRegion,
          operatingHours: _hoursController.text.trim().isNotEmpty
              ? _hoursController.text.trim()
              : null,
          ownerUid: user.uid,
        );
        await ref.read(donationRepositoryProvider).createOrganization(org);
      }

      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파트너 신청이 완료되었습니다. 관리자 승인을 기다려주세요.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showWishBooks = _partnerType == 'donationOrg' || _partnerType == 'library';
    return Scaffold(
      appBar: AppBar(title: const Text('파트너 신청')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      Text('파트너 안내', style: AppTypography.titleSmall.copyWith(color: AppColors.info)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      '파트너로 등록하면 중고서점, 기부단체, 도서관으로 활동할 수 있습니다.\n'
                      '사업자등록증 첨부 후 관리자 승인이 필요합니다.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 파트너 유형 선택
              Text('파트너 유형', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'bookstore', label: Text('중고서점'), icon: Icon(Icons.store)),
                  ButtonSegment(value: 'donationOrg', label: Text('기부단체'), icon: Icon(Icons.volunteer_activism)),
                  ButtonSegment(value: 'library', label: Text('도서관'), icon: Icon(Icons.local_library)),
                ],
                selected: {_partnerType},
                onSelectionChanged: (v) => setState(() => _partnerType = v.first),
              ),
              const SizedBox(height: 20),

              // 상호명
              Text('상호명', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: '상호명을 입력하세요', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '상호명을 입력해주세요';
                  if (v.trim().length < 2) return '2글자 이상 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 설명
              Text('소개', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(hintText: '간단한 소개를 입력하세요', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 연락처
              Text('연락처', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(hintText: '전화번호', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // 주소 + GPS
              Text('주소', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(hintText: '주소를 입력하세요', border: OutlineInputBorder()),
                    onChanged: _onAddressChanged,
                    validator: (v) => (v == null || v.trim().isEmpty) ? '주소를 입력해주세요' : null,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isDetectingGps ? null : _detectGps,
                    icon: _isDetectingGps
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.my_location, size: 18),
                    label: const Text('GPS'),
                  ),
                ),
              ]),
              if (_region != null) ...[
                const SizedBox(height: 4),
                Text('$_region ${_subRegion ?? ''}', style: AppTypography.caption.copyWith(color: AppColors.success)),
              ],
              const SizedBox(height: 16),

              // 운영시간
              Text('운영시간', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(hintText: '예: 09:00 - 18:00', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // === 사업자등록증 ===
              Text('사업자등록증', style: AppTypography.labelLarge),
              const SizedBox(height: 4),
              Text('승인을 위해 사업자등록증 사본을 첨부해주세요', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickLicenseImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(
                      color: _licenseBytes == null ? AppColors.divider : AppColors.success,
                      width: _licenseBytes == null ? 1 : 2,
                    ),
                  ),
                  child: _licenseBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMD - 1),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(_licenseBytes!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => setState(() {
                                      _licenseBytes = null;
                                      _licenseFileName = null;
                                    }),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('첨부 완료', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 40, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text('사업자등록증 이미지를 선택하세요', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('탭하여 갤러리에서 선택', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 희망도서 (기부단체/도서관만)
              if (showWishBooks) ...[
                Text('희망 도서 장르', style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text('받고 싶은 도서 장르를 선택하세요', style: AppTypography.caption),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: BookGenre.values.where((g) => g != BookGenre.all).map((genre) {
                    final selected = _selectedWishGenres.contains(genre.label);
                    return FilterChip(
                      label: Text(genre.label),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedWishGenres.add(genre.label);
                          } else {
                            _selectedWishGenres.remove(genre.label);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // 제출
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('파트너 신청'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
