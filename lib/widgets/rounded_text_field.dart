import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Campo de texto redondeado con estilo CleanClip.
class RoundedTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool showClearButton;
  final TextInputType keyboardType;
  final bool readOnly;
  final int maxLines;

  const RoundedTextField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixWidget,
    this.showClearButton = false,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildField() {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.secondary, size: 22)
                : null,
            suffixIcon: _buildSuffixIcon(),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            filled: false,
          ),
          cursorColor: AppColors.primary,
        ),
      );
    }

    if (!showClearButton || controller == null) return buildField();

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller!,
      builder: (context, value, _) => buildField(),
    );
  }

  Widget? _buildSuffixIcon() {
    if (suffixWidget != null) return suffixWidget;
    if (!showClearButton || controller == null || controller!.text.isEmpty) {
      return null;
    }

    return IconButton(
      tooltip: 'Limpiar',
      icon: const Icon(
        Icons.close_rounded,
        color: AppColors.textHint,
        size: 20,
      ),
      onPressed: () {
        controller!.clear();
        onChanged?.call('');
      },
    );
  }
}
