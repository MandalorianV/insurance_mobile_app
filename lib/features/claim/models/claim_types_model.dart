import 'package:freezed_annotation/freezed_annotation.dart';

// Burada 's' harfine dikkat et (dosya adınla aynı olmalı)
part 'claim_types_model.freezed.dart';
part 'claim_types_model.g.dart';

@freezed
abstract class ClaimType with _$ClaimType {
  const factory ClaimType({
    required String id,
    required String label,
    required String emoji,
  }) = _ClaimType;

  factory ClaimType.fromJson(Map<String, dynamic> json) =>
      _$ClaimTypeFromJson(json);
}
