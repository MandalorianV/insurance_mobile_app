import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/core/widgets/shimmer_widgets.dart';
import 'package:insurance_mobile_app/features/claim/bloc/claim_bloc.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view_mixin.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimView extends StatefulWidget {
  final InsuranceModel insurance;
  const ClaimView({super.key, required this.insurance});

  @override
  State<ClaimView> createState() => _ClaimViewState();
}

class _ClaimViewState extends State<ClaimView> with ClaimViewMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClaimBloc(ClaimRepository(claimServices!))
            ..add(GetClaimTypesEvent(id: widget.insurance.id)),
      child: BlocListener<ClaimBloc, ClaimState>(
        listener: (context, state) {
          if (state is ClaimTypesError ||
              state is ClaimSubmissionError ||
              state is ClaimRecordsError) {
            final error = switch (state) {
              ClaimTypesError s => s.error,
              ClaimSubmissionError s => s.error,
              ClaimRecordsError s => s.error,
              _ => AppError.unknown,
            };

            context.push('/noInternet', extra: error).then((_) async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future.delayed(const Duration(milliseconds: 1500));
              if (!context.mounted) return;
              context.read<ClaimBloc>().add(RetryLastEvent());
            });
          }
        },
        child: Scaffold(
          body: BlocBuilder<ClaimBloc, ClaimState>(
            buildWhen: (previous, current) =>
                current is GetClaimTypesState ||
                current is ClaimStepUpState ||
                current is ClaimSubmissionSuccess ||
                current is ClaimSubmitting,
            builder: (context, state) {
              if (state is GetClaimTypesState) {
                claimTypes = state.claimTypes;
              }
              if (state is ClaimStepUpState) {
                step = state.step;
              }
              if (state is ClaimSubmissionSuccess) {
                return _buildSuccessScreen();
              }

              final isSubmitting = state is ClaimSubmitting;

              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: step == 1
                          ? _buildStep1()
                          : step == 2
                          ? _buildStep2()
                          : _buildStep3(),
                    ),
                  ),
                  _buildBottomButton(context, isSubmitting),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return switch (widget.insurance.category) {
      'vehicle' => _buildStep2ForVehicle(),
      'health' => _buildStep2ForHealth(),
      'home' => _buildStep2ForHome(),
      'travel' => _buildStep2ForTravel(),
      _ => _buildStep2ForVehicle(),
    };
  }

  Widget _buildHeader() {
    final stepLabels = switch (widget.insurance.category) {
      'vehicle' => ['Kaza Türü', 'Kaza Detayları', 'İletişim'],
      'health' => ['Tedavi Türü', 'Tedavi Detayları', 'İletişim'],
      'home' => ['Hasar Türü', 'Hasar Detayları', 'İletişim'],
      'travel' => ['Olay Türü', 'Olay Detayları', 'İletişim'],
      _ => ['Hasar Türü', 'Olay Detayları', 'İletişim'],
    };
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: context.appColors.textPrimary,
                      size: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(switch (widget.insurance.category) {
                      'vehicle' => 'Kaza Bildirimi',
                      'health' => 'Tedavi Bildirimi',
                      'home' => 'Hasar Bildirimi',
                      'travel' => 'Olay Bildirimi',
                      _ => 'Hasar Bildirimi',
                    }, style: context.textTheme.headlineLarge),
                    Text(
                      '${widget.insurance.type} · ${widget.insurance.policyNo}',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Step progress bar
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: index < step
                          ? context.appColors.accent
                          : context.appColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              'Adım $step/3 · ${stepLabels[step - 1]}',
              style: context.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(switch (widget.insurance.category) {
          'vehicle' => 'Kaza türünü seçin:',
          'health' => 'Tedavi türünü seçin:',
          'home' => 'Hasar türünü seçin:',
          'travel' => 'Olay türünü seçin:',
          _ => 'Hasar türünü seçin:',
        }, style: context.textTheme.bodyMedium),
        const SizedBox(height: 16),
        BlocBuilder<ClaimBloc, ClaimState>(
          buildWhen: (previous, current) => current is SelectedDamageTypeState,
          builder: (context, state) {
            if (state is SelectedDamageTypeState) {
              selectedDamageType = state.damageType;
              selectedClaimTypeId = claimTypes
                  .firstWhere((type) => type.label == state.damageType)
                  .id;
            }
            if (claimTypes.isEmpty) {
              return const SingleChildScrollView(
                child: Column(children: [ClaimTypesShimmer()]),
              );
            }

            return Column(
              children: claimTypes.map((ct) {
                final isSelected =
                    selectedClaimTypeId == ct.id; // 👈 artık builder içinde

                return GestureDetector(
                  onTap: () {
                    context.read<ClaimBloc>().add(
                      SelectDamageTypeEvent(damageType: ct.label),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.appColors.accentSoft
                          : context.appColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? context.appColors.accent
                            : context.appColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(ct.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            ct.label,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: context.appColors.accent,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2ForVehicle() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Olay bilgilerini girin:', style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'Tarih & Saat',
            controller: dateController,
            hint: 'gg.aa.yyyy ss:dd',
            onTap: dateTimeSelectionOnTap,
            validator: (v) =>
                v == null || v.isEmpty ? 'Tarih seçimi zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Olay Yeri',
            controller: locationController,
            hint: 'Şehir, Semt, Sokak...',
            validator: (v) =>
                v == null || v.isEmpty ? 'Olay yeri zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Plaka (varsa)',
            controller: plateController,
            hint: '34 ABC 123',
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Olay Açıklaması',
            controller: descController,
            hint: 'Hasarı kısaca açıklayın...',
            maxLines: 4,
            validator: (v) =>
                v == null || v.isEmpty ? 'Açıklama zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep2ForHealth() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tedavi bilgilerini girin:',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'Tedavi Tarihi',
            controller: dateController,
            hint: 'gg.aa.yyyy ss:dd',
            onTap: dateTimeSelectionOnTap,
            validator: (v) =>
                v == null || v.isEmpty ? 'Tarih seçimi zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Hastane / Klinik',
            controller: hospitalController,
            hint: 'Hastane adı ve şehir...',
            validator: (v) =>
                v == null || v.isEmpty ? 'Hastane bilgisi zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Tanı / Tedavi Türü',
            controller: diagnosisController,
            hint: 'Ameliyat, muayene, tahlil...',
            validator: (v) =>
                v == null || v.isEmpty ? 'Tedavi türü zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Açıklama',
            controller: descController,
            hint: 'Tedavi sürecini kısaca açıklayın...',
            maxLines: 4,
            validator: (v) =>
                v == null || v.isEmpty ? 'Açıklama zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep2ForHome() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hasar bilgilerini girin:', style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'Olay Tarihi',
            controller: dateController,
            hint: 'gg.aa.yyyy ss:dd',
            onTap: dateTimeSelectionOnTap,
            validator: (v) =>
                v == null || v.isEmpty ? 'Tarih seçimi zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Konut Adresi',
            controller: addressController,
            hint: 'İl, İlçe, Sokak, No...',
            validator: (v) =>
                v == null || v.isEmpty ? 'Adres zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Hasar Yeri',
            controller: damageAreaController,
            hint: 'Mutfak, salon, banyo...',
            validator: (v) =>
                v == null || v.isEmpty ? 'Hasar yeri zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Hasar Açıklaması',
            controller: descController,
            hint: 'Hasarı kısaca açıklayın...',
            maxLines: 4,
            validator: (v) =>
                v == null || v.isEmpty ? 'Açıklama zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep2ForTravel() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Olay bilgilerini girin:', style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'Olay Tarihi',
            controller: dateController,
            hint: 'gg.aa.yyyy ss:dd',
            onTap: dateTimeSelectionOnTap,
            validator: (v) =>
                v == null || v.isEmpty ? 'Tarih seçimi zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Ülke / Şehir',
            controller: countryController,
            hint: 'Almanya, Berlin...',
            validator: (v) =>
                v == null || v.isEmpty ? 'Ülke/Şehir zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'Olay Açıklaması',
            controller: descController,
            hint: 'Bagaj kaybı, uçuş gecikmesi, acil tedavi...',
            maxLines: 4,
            validator: (v) =>
                v == null || v.isEmpty ? 'Açıklama zorunludur' : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: formKeyStepThree,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İletişim bilgileri:', style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _formField(
            label: 'Telefon',
            controller: phoneController,
            hint: '05XX XXX XX XX',
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Telefon numarası zorunludur';
              final digits = v.replaceAll(RegExp(r'\D'), '');
              // +90 5XX XXX XX XX → 12 hane, veya 05XX XXX XX XX → 11 hane
              final normalized = digits.startsWith('90') ? digits : '90$digits';
              if (!RegExp(r'^905[0-9]{9}$').hasMatch(normalized)) {
                return 'Geçerli bir telefon numarası girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bildirim Özeti',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _summaryRow('Poliçe', widget.insurance.type),
                const SizedBox(height: 8),
                _summaryRow('Hasar Türü', selectedDamageType),
                const SizedBox(height: 8),
                _summaryRow(
                  'Tarih',
                  dateController.text.isEmpty ? '-' : dateController.text,
                ),
                const SizedBox(height: 8),
                _summaryRow(
                  switch (widget.insurance.category) {
                    'vehicle' => 'Olay Yeri',
                    'health' => 'Hastane / Klinik',
                    'home' => 'Konut Adresi',
                    'travel' => 'Ülke / Şehir',
                    _ => 'Konum',
                  },
                  switch (widget.insurance.category) {
                    'vehicle' =>
                      locationController.text.isEmpty
                          ? '-'
                          : locationController.text,
                    'health' =>
                      hospitalController.text.isEmpty
                          ? '-'
                          : hospitalController.text,
                    'home' =>
                      addressController.text.isEmpty
                          ? '-'
                          : addressController.text,
                    'travel' =>
                      countryController.text.isEmpty
                          ? '-'
                          : countryController.text,
                    _ => '-',
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textTheme.bodySmall),
        Text(value, style: context.textTheme.labelMedium),
      ],
    );
  }

  Widget _formField({
    FormFieldValidator<String>? validator,
    bool readOnly = false,
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          onTapUpOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      color: context.appColors.bg,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.appColors.accent, context.appColors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.appColors.accent.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => stepUpOnPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    step == 3
                        ? switch (widget.insurance.category) {
                            'vehicle' => 'Kaza Bildir',
                            'health' => 'Tedavi Bildir',
                            'home' => 'Hasar Bildir',
                            'travel' => 'Olay Bildir',
                            _ => 'Bildirimi Gönder',
                          }
                        : 'Devam Et →',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    final (title, subtitle, info) = switch (widget.insurance.category) {
      'vehicle' => (
        'Kaza Bildirimi Alındı!',
        'Kaza bildiriminiz başarıyla oluşturuldu.',
        'Eksper en kısa sürede sizinle iletişime geçecektir. Tahmini süre 24-48 saat.',
      ),
      'health' => (
        'Tedavi Bildirimi Alındı!',
        'Tedavi bildiriminiz başarıyla oluşturuldu.',
        'Sağlık danışmanımız en kısa sürede sizinle iletişime geçecektir. Tahmini süre 24-48 saat.',
      ),
      'home' => (
        'Hasar Bildirimi Alındı!',
        'Konut hasar bildiriminiz başarıyla oluşturuldu.',
        'Konut eksperi en kısa sürede sizinle iletişime geçecektir. Tahmini süre 24-48 saat.',
      ),
      'travel' => (
        'Olay Bildirimi Alındı!',
        'Seyahat olay bildiriminiz başarıyla oluşturuldu.',
        'Seyahat destek ekibimiz en kısa sürede sizinle iletişime geçecektir. Tahmini süre 24-48 saat.',
      ),
      _ => (
        'Bildirim Alındı!',
        'Bildiriminiz başarıyla oluşturuldu.',
        'Eksper en kısa sürede sizinle iletişime geçecektir. Tahmini süre 24-48 saat.',
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.success.withOpacity(0.13),
                  border: Border.all(
                    color: context.appColors.success,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: context.appColors.success,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: context.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('#HDR-2025-08741', style: context.textTheme.headlineSmall),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.appColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('⏱', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(info, style: context.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.appColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Poliçelerime Dön',
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(BuildContext context) {
    return ValueListenableBuilder<List<XFile>>(
      valueListenable: photosNotifier,
      builder: (context, photoList, _) {
        if (photoList.isEmpty) {
          return GestureDetector(
            onTap: () => addPhotoOnTap(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: context.appColors.card.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.appColors.border,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Text('📷', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Fotoğraf Ekle', style: context.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Hasar fotoğrafları süreci hızlandırır',
                    style: context.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photoList.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == photoList.length) {
                return GestureDetector(
                  onTap: () => addPhotoOnTap(context),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: context.appColors.card.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.appColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: context.appColors.textSub,
                      size: 32,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photoList[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => removePhoto(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
