// lib/features/farm_config/widgets/shared_widgets.dart
// Widgets réutilisables partagés entre les onglets de farm_config.

import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

// ─────────────────────────────────────────────────────────────────
// Étiquettes
// ─────────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.muted,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.5,
    ),
  );
}

class StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const StepTitle(this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.dark,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    ],
  );
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.muted,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Ligne d'information (icône + label + valeur)
// ─────────────────────────────────────────────────────────────────

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const InfoRow(this.icon, this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Séparateur
// ─────────────────────────────────────────────────────────────────

class KiwoDivider extends StatelessWidget {
  const KiwoDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(color: AppColors.dark.withOpacity(0.06), height: 1, indent: 16);
}

// ─────────────────────────────────────────────────────────────────
// Boutons navigation wizard
// ─────────────────────────────────────────────────────────────────

class NextButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const NextButton(
    this.label, {
    required this.enabled,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: enabled ? AppColors.orange : AppColors.muted.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: enabled ? AppColors.cream : AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_rounded,
            color: enabled ? AppColors.yellow : AppColors.muted,
            size: 17,
          ),
        ],
      ),
    ),
  );
}

class WizardBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const WizardBackButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.dark.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AppColors.dark,
        size: 18,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Champ de texte stylisé
// ─────────────────────────────────────────────────────────────────

class KiwoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final String suffix;
  final TextInputType keyboard;
  final ValueChanged<String> onChanged;

  const KiwoTextField({
    required this.controller,
    required this.hint,
    this.icon,
    required this.suffix,
    required this.keyboard,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    onChanged: onChanged,
    style: const TextStyle(
      color: AppColors.dark,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.muted.withOpacity(0.5),
        fontSize: 14,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: AppColors.muted, size: 18),
      suffixText: suffix,
      suffixStyle: const TextStyle(
        color: AppColors.muted,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.dark.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.dark.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.orange, width: 2),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Cartes de seuils (sliders)
// ─────────────────────────────────────────────────────────────────

class ThresholdCard extends StatelessWidget {
  final IconData icon;
  final String label, unit;
  final Color color;
  final double minVal, maxVal, absMin, absMax;
  final ValueChanged<double> onMinChanged, onMaxChanged;

  const ThresholdCard({
    required this.icon,
    required this.label,
    required this.unit,
    required this.color,
    required this.minVal,
    required this.maxVal,
    required this.absMin,
    required this.absMax,
    required this.onMinChanged,
    required this.onMaxChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.dark.withOpacity(0.07)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.dark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SliderRow(
          label: 'MIN',
          val: minVal,
          min: absMin,
          max: absMax,
          unit: unit,
          color: color,
          onChange: (v) {
            if (v < maxVal - 1) onMinChanged(v);
          },
        ),
        const SizedBox(height: 4),
        _SliderRow(
          label: 'MAX',
          val: maxVal,
          min: absMin,
          max: absMax,
          unit: unit,
          color: color,
          onChange: (v) {
            if (v > minVal + 1) onMaxChanged(v);
          },
        ),
      ],
    ),
  );
}

class SingleThresholdCard extends StatelessWidget {
  final IconData icon;
  final String label, unit, description;
  final Color color;
  final double value, min, max;
  final ValueChanged<double> onChanged;

  const SingleThresholdCard({
    required this.icon,
    required this.label,
    required this.unit,
    required this.color,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.dark.withOpacity(0.07)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.dark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _SliderRow(
          label: '',
          val: value,
          min: min,
          max: max,
          unit: unit,
          color: color,
          onChange: onChanged,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: AppColors.muted.withOpacity(0.7),
            fontSize: 10.5,
          ),
        ),
      ],
    ),
  );
}

class _SliderRow extends StatelessWidget {
  final String label, unit;
  final double val, min, max;
  final Color color;
  final ValueChanged<double> onChange;

  const _SliderRow({
    required this.label,
    required this.val,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (label.isNotEmpty)
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: AppColors.dark.withOpacity(0.08),
            overlayColor: color.withOpacity(0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).toInt().clamp(1, 200),
            onChanged: onChange,
          ),
        ),
      ),
      Container(
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            '${val.toStringAsFixed(0)}$unit',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────
// Bottom sheet générique
// ─────────────────────────────────────────────────────────────────

class KiwoBottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const KiwoBottomSheet({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dark.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: AppColors.orange, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// Champ dans bottom sheet
// ─────────────────────────────────────────────────────────────────

class SheetField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboard;

  const SheetField(
    this.label,
    this.ctrl,
    this.icon, {
    this.obscure = false,
    this.keyboard = TextInputType.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 7),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(
          color: AppColors.dark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.muted, size: 18),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.dark.withOpacity(0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.dark.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.orange, width: 2),
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────
// Bouton de sauvegarde dans bottom sheet
// ─────────────────────────────────────────────────────────────────

class SheetSaveButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const SheetSaveButton(
    this.label, {
    required this.loading,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: loading ? AppColors.muted.withOpacity(0.3) : AppColors.dark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.cream,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.yellow,
                    size: 17,
                  ),
                ],
              ),
      ),
    ),
  );
}
