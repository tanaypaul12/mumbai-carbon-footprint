// lib/screens/energy_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_input.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class EnergyScreen extends StatefulWidget {
  final CalculatorInput input;
  final VoidCallback onNext;
  const EnergyScreen({super.key, required this.input, required this.onNext});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  late CalculatorInput _i;

  @override
  void initState() {
    super.initState();
    _i = widget.input;
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(icon: '⚡', title: 'Household Energy'),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInputField(
          label: 'Monthly Electricity Bill',
          prefix: '₹ ',
          value: _i.electricityBill,
          onChanged: (v) => setState(() => _i.electricityBill = v),
        ),
        const SizedBox(height: 6),
        Text(
          'Avg Mumbai tariff: ₹5.50/kWh (MSEDCL domestic)',
          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
        ),
      ])),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SliderField(
          label: 'LPG Cylinders per Month',
          value: _i.lpgCylinders,
          min: 0, max: 4,
          divisions: 8,
          suffix: ' cyl',
          onChanged: (v) => setState(() => _i.lpgCylinders = v),
        ),
        const SizedBox(height: 4),
        Text('14.2 kg cylinder', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 20),
        NumberInputField(
          label: 'Piped Gas (PNG) Monthly Bill',
          prefix: '₹ ',
          hint: '0 if not applicable',
          value: _i.pngBill,
          onChanged: (v) => setState(() => _i.pngBill = v),
        ),
        const SizedBox(height: 4),
        Text('MGL piped gas rate ≈ ₹32/SCM', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
      ])),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SliderField(
          label: 'Household Members',
          value: _i.householdMembers.toDouble(),
          min: 1, max: 10,
          divisions: 9,
          suffix: ' people',
          onChanged: (v) => setState(() => _i.householdMembers = v.round()),
        ),
      ])),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Air Conditioning Usage', style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
        )),
        const SizedBox(height: 12),
        ChipSelector<int>(
          selected: _i.acUsage,
          onChanged: (v) => setState(() => _i.acUsage = v),
          options: const [
            ChipOption(value: 0, label: 'No AC'),
            ChipOption(value: 1, label: '1-2 months/yr'),
            ChipOption(value: 2, label: '3-5 months/yr'),
            ChipOption(value: 3, label: '6+ months/yr'),
          ],
        ),
      ])),

      NavButtons(onNext: widget.onNext, nextLabel: 'Transport →'),
    ]),
  );
}
