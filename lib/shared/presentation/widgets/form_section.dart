import 'package:flutter/material.dart';

/// Widget réutilisable pour organiser les formulaires en sections
class FormSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const FormSection({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color:
          backgroundColor ??
          (isDark
              ? theme.cardColor
              : theme.colorScheme.surfaceVariant.withOpacity(0.3)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              children.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < children.length - 1 ? 12 : 0,
                ),
                child: children[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Input décorée pour les champs de formulaire
class DecoratedFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final int maxLines;
  final int minLines;

  const DecoratedFormField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSaved,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
    );
  }
}

/// Dropdown décorée pour les listes de sélection
class DecoratedDropdown<T> extends StatelessWidget {
  final String label;
  final IconData? icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const DecoratedDropdown({
    super.key,
    required this.label,
    this.icon,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
    );
  }
}
