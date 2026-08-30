import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template contribution_field}
/// A labelled text input in the submission form.
///
/// Plain and dark rather than glass: this is the one surface in the app where
/// the user is writing rather than reading, and a refracting background behind
/// a caret is difficult to work in.
/// {@endtemplate}
class ContributionField extends StatelessWidget {
  /// {@macro contribution_field}
  const ContributionField({
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.minLines = 1,
    this.maxLines = 1,
    super.key,
  });

  /// The label above the field.
  final String label;

  /// The field's controller.
  final TextEditingController controller;

  /// Placeholder text.
  final String? hint;

  /// A line of guidance under the field.
  final String? helper;

  /// Minimum visible lines.
  final int minLines;

  /// Maximum visible lines.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.labelSmall?.copyWith(
            color: context.gi.textSecondary,
            letterSpacing: 1.4,
            fontSize: 9.5,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          style: context.bodyMedium?.copyWith(
            color: context.gi.textPrimary,
            height: 1.45,
          ),
          cursorColor: context.gi.action,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: context.bodyMedium?.copyWith(
              color: context.gi.textSecondary,
            ),
            filled: true,
            fillColor: context.gi.fill,
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            border: _border(context.gi.hairline),
            enabledBorder: _border(context.gi.hairline),
            focusedBorder: _border(context.gi.action, 1.5),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helper!,
            style: context.labelSmall?.copyWith(
              color: context.gi.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        borderSide: BorderSide(color: color, width: width),
      );
}
