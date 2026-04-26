import 'package:freezed_annotation/freezed_annotation.dart';

part 'claim_record_model.freezed.dart';
part 'claim_record_model.g.dart';

@freezed
abstract class ClaimRecord with _$ClaimRecord {
  const factory ClaimRecord({
    @JsonKey(name: 'ref_no') required String refNo,
    @JsonKey(name: 'policy_no') required String policyNo,
    @JsonKey(name: 'claim_type_id') required String claimTypeId,
    @JsonKey(name: 'claim_type_label') required String claimTypeLabel,
    @JsonKey(name: 'claim_type_emoji') required String claimTypeEmoji,
    @JsonKey(name: 'incident_date') required String incidentDate,
    required String location,
    String? plate,
    required String description,
    required String phone,
    String? email,
    required String status, // pending | in_progress | approved | rejected
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _ClaimRecord;

  factory ClaimRecord.fromJson(Map<String, dynamic> json) =>
      _$ClaimRecordFromJson(json);
}
