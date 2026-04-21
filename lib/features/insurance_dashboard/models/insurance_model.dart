import 'package:freezed_annotation/freezed_annotation.dart';

part 'insurance_model.freezed.dart';
part 'insurance_model.g.dart';

@freezed
abstract class InsuranceModel with _$InsuranceModel {
  const factory InsuranceModel({
    required String id,
    required String type, // Vehicle, Health, Home
    required String title,
    required String status, // Active, Expiring
    required String provider,

    @JsonKey(name: 'coverage_amount') required double coverageAmount,

    @JsonKey(name: 'start_date') required String startDate,

    @JsonKey(name: 'end_date') required String endDate,

    @JsonKey(name: 'icon_type') required String iconType, // car, health, home
  }) = _InsuranceModel;

  factory InsuranceModel.fromJson(Map<String, dynamic> json) =>
      _$InsuranceModelFromJson(json);
}
