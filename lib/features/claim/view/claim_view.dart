import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurance_mobile_app/features/claim/bloc/claim_bloc.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view_mixin.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/app_theme.dart';

class ClaimView extends StatefulWidget {
  final InsuranceModel insurance;
  const ClaimView({super.key, required this.insurance});

  @override
  State<ClaimView> createState() => _ClaimViewState();
}

class _ClaimViewState extends State<ClaimView> with ClaimViewMixin {
  @override
  Widget build(BuildContext context) {
    if (submitted) return _buildSuccessScreen();

    return BlocProvider(
      create: (context) =>
          ClaimBloc(ClaimRepository(claimServices!))
            ..add(GetClaimTypesEvent()), //TODO: null safety check important!!
      child: Scaffold(
        body: BlocBuilder<ClaimBloc, ClaimState>(
          builder: (context, state) {
            if (state is GetClaimTypes) {
              claimTypes = state.claimTypes;
            }
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
                _buildBottomButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stepLabels = ['Hasar Türü', 'Olay Detayları', 'İletişim'];
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
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasar Bildirimi',
                      style: AppTextStyles.heading.copyWith(fontSize: 18),
                    ),
                    Text(
                      '${widget.insurance.type} · ${widget.insurance.policyNo}',
                      style: AppTextStyles.muted.copyWith(fontSize: 12),
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
                      color: index < step ? AppColors.accent : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              'Adım $step/3 · ${stepLabels[step - 1]}',
              style: AppTextStyles.muted.copyWith(fontSize: 11),
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
        Text(
          'Hasar türünü seçin:',
          style: AppTextStyles.sub.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...claimTypes.map((ct) {
          final isSelected = selectedClaimTypeId == ct.id;
          return GestureDetector(
            onTap: () => setState(() => selectedClaimTypeId = ct.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentSoft : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
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
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olay bilgilerini girin:',
          style: AppTextStyles.sub.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _formField(
          label: 'Tarih & Saat',
          controller: dateController,
          hint: 'gg.aa.yyyy ss:dd',
        ),
        const SizedBox(height: 14),
        _formField(
          label: 'Olay Yeri',
          controller: locationController,
          hint: 'Şehir, Semt, Sokak...',
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
        ),
        const SizedBox(height: 14),
        // Photo upload placeholder
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const Text('📷', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  'Fotoğraf Ekle',
                  style: AppTextStyles.sub.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hasar fotoğrafları süreci hızlandırır',
                  style: AppTextStyles.muted.copyWith(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İletişim bilgileri:',
          style: AppTextStyles.sub.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _formField(
          label: 'Telefon',
          controller: phoneController,
          hint: '05XX XXX XX XX',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bildirim Özeti',
                style: AppTextStyles.sub.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _summaryRow('Poliçe', widget.insurance.type),
              const SizedBox(height: 8),
              _summaryRow('Hasar Türü', "selectedType.label"),
              const SizedBox(height: 8),
              _summaryRow(
                'Tarih',
                dateController.text.isEmpty ? '-' : dateController.text,
              ),
              const SizedBox(height: 8),
              _summaryRow(
                'Konum',
                locationController.text.isEmpty ? '-' : locationController.text,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.muted.copyWith(fontSize: 12)),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _formField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.sub.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.body.copyWith(fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final isLastStep = step == 3;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      color: AppColors.bg,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (!isLastStep) {
                setState(() => step++);
              } else {
                setState(() => submitted = true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              isLastStep ? 'Bildirimi Gönder' : 'Devam Et →',
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
                  color: AppColors.success.withOpacity(0.13),
                  border: Border.all(color: AppColors.success, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bildirim Alındı!',
                style: AppTextStyles.heading.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hasar bildiriminiz başarıyla oluşturuldu.',
                style: AppTextStyles.sub.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '#HDR-2025-08741',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('⏱', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Eksper en kısa sürede sizinle iletişime geçecektir. Tahmini süre 24-48 saat.',
                        style: AppTextStyles.sub.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Poliçelerime Dön',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
