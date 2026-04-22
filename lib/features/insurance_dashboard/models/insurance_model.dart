import 'package:freezed_annotation/freezed_annotation.dart';

part 'insurance_model.freezed.dart';
part 'insurance_model.g.dart';

@freezed
abstract class InsuranceModel with _$InsuranceModel {
  const factory InsuranceModel({
    required int id,
    required String type,
    required String subtitle,
    required String emoji,
    required String status,
    @JsonKey(name: 'status_color') required String statusColorHex,
    @JsonKey(name: 'policy_no') required String policyNo,
    required String expiry,
    required String premium,
    required String period,
    required String coverage,
    @JsonKey(name: 'gradient_hex') required List<String> gradientHex,
    @JsonKey(name: 'claims_count') required int claimsCount,
    @JsonKey(name: 'coverage_items') required List<CoverageItem> coverageItems,
  }) = _InsuranceModel;

  factory InsuranceModel.fromJson(Map<String, dynamic> json) =>
      _$InsuranceModelFromJson(json);
}

@freezed
abstract class CoverageItem with _$CoverageItem {
  const factory CoverageItem({
    required String name,
    required String limit,
    required bool covered,
  }) = _CoverageItem;

  factory CoverageItem.fromJson(Map<String, dynamic> json) =>
      _$CoverageItemFromJson(json);
}
