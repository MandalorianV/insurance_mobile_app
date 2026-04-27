import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const ClaimSummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textTheme.bodySmall),
        Text(value, style: context.textTheme.labelMedium),
      ],
    );
  }
}
