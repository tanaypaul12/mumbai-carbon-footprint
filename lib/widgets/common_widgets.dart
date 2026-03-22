// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

// ── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  const SectionHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 10),
      Text(title, style: GoogleFonts.syne(
        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
      )),
    ]),
  );
}

// ── Card Container ───────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  const AppCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: padding ?? const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: AppColors.greenDeep.withOpacity(0.06),
          blurRadius: 16, offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

// ── Chip Selector ────────────────────────────────────────────
class ChipSelector<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  const ChipSelector({
    super.key, required this.options,
    required this.selected, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: options.map((opt) {
      final isSelected = opt.value == selected;
      return GestureDetector(
        onTap: () => onChanged(opt.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.greenDeep : AppColors.surface2,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? AppColors.greenDeep : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            opt.label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textMid,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

class ChipOption<T> {
  final T value;
  final String label;
  const ChipOption({required this.value, required this.label});
}

// ── Slider Field ─────────────────────────────────────────────
class SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;
  const SliderField({
    super.key, required this.label, required this.value,
    required this.min, required this.max,
    this.divisions = 20, this.suffix = '',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
        )),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.greenPale,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$suffix',
            style: GoogleFonts.syne(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.greenMid,
            ),
          ),
        ),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.greenMid,
          inactiveTrackColor: AppColors.greenPale,
          thumbColor: AppColors.greenDeep,
          overlayColor: AppColors.greenDeep.withOpacity(0.12),
          trackHeight: 5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        ),
        child: Slider(
          value: value, min: min, max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

// ── Number Input ─────────────────────────────────────────────
class NumberInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final double value;
  final ValueChanged<double> onChanged;
  const NumberInputField({
    super.key, required this.label, required this.value,
    required this.onChanged, this.hint, this.prefix, this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value == 0 ? '' : value.toInt().toString(),
    keyboardType: TextInputType.number,
    style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textDark),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
    ),
    onChanged: (s) => onChanged(double.tryParse(s) ?? 0),
  );
}

// ── Step Progress Bar ─────────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final List<String> labels;
  const StepProgressBar({
    super.key, required this.current,
    required this.total, required this.labels,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(total, (i) {
      final isActive   = i == current;
      final isComplete = i < current;
      return Expanded(
        child: Row(children: [
          Expanded(
            child: Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: isComplete || isActive
                      ? AppColors.greenAccent
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.greenDeep : AppColors.textMuted,
                ),
              ),
            ]),
          ),
          if (i < total - 1) const SizedBox(width: 4),
        ]),
      );
    }),
  );
}

// ── Navigation Buttons ────────────────────────────────────────
class NavButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final bool isLoading;
  const NavButtons({
    super.key, this.onBack, required this.onNext,
    this.nextLabel = 'Next', this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Row(children: [
      if (onBack != null) ...[
        OutlinedButton(
          onPressed: onBack,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.greenDeep,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: Text('← Back', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: ElevatedButton(
          onPressed: isLoading ? null : onNext,
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(nextLabel),
        ),
      ),
    ]),
  );
}
