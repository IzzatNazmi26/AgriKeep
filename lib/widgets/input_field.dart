import 'package:flutter/material.dart';
import 'package:agrikeep/utils/theme.dart';

class InputField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final int? maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autoFocus;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
  final bool required;
  final List<String>? options;
  final String? selectedOption;
  final ValueChanged<String?>? onOptionSelected;
  final String? unit;

  const InputField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.autoFocus = false,
    this.maxLength,
    this.validator,
    this.required = false,
    this.options,
    this.selectedOption,
    this.onOptionSelected,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isDropdown = options != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AgriKeepTheme.textPrimary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: AgriKeepTheme.errorColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isDropdown)
          _buildDropdown()
        else
          _buildTextField(),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: AgriKeepTheme.errorColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField() {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          initialValue: controller == null ? value : null,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          autofocus: autoFocus,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: AgriKeepTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AgriKeepTheme.textTertiary,
            ),
            filled: true,
            fillColor: enabled
                ? AgriKeepTheme.surfaceColor
                : AgriKeepTheme.backgroundColor,
            contentPadding: EdgeInsets.fromLTRB(
              prefixIcon != null ? 48 : 16,
              12,
              suffixIcon != null || unit != null ? 48 : 16,
              12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AgriKeepTheme.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AgriKeepTheme.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AgriKeepTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AgriKeepTheme.errorColor,
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AgriKeepTheme.borderColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
        if (unit != null)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                unit!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AgriKeepTheme.textTertiary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AgriKeepTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorText != null && errorText!.isNotEmpty
              ? AgriKeepTheme.errorColor
              : AgriKeepTheme.borderColor,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: selectedOption,
          onChanged: onOptionSelected,
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                'Select $label',
                style: const TextStyle(
                  color: AgriKeepTheme.textTertiary,
                ),
              ),
            ),
            ...options!.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ],
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AgriKeepTheme.textTertiary,
          ),
          isExpanded: true,
          style: const TextStyle(
            fontSize: 16,
            color: AgriKeepTheme.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}