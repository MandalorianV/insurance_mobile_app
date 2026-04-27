import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;

  const ClaimFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          onTapUpOutside: (event) => FocusScope.of(context).unfocus(),
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
