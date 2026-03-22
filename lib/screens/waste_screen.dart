// lib/screens/waste_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_input.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class WasteScreen extends StatefulWidget {
  final CalculatorInput input;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isLoading;
  const WasteScreen({super.key, required this.input, required this.onBack, required this.onNext, this.isLoading = false});

  @override
  State<WasteScreen> createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen> {
  late CalculatorInput _i;

  @override
  void initState() { super.initState(); _i = widget.input; }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(icon: '🗑', title: 'Waste & Consumption'),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Household Waste Segregation (BMC)', style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
        )),
        const SizedBox(height: 12),
        ChipSelector<String>(
          selected: _i.wasteSeg,
          onChanged: (v) => setState(() => _i.wasteSeg = v),
          options: const [
            ChipOption(value: 'none', label: 'None'),
            ChipOption(value: 'some', label: 'Partial segregation'),
            ChipOption(value: 'full', label: 'Full dry/wet split'),
          ],
        ),
      ])),

      AppCard(child: Column(children: [
        SliderField(
          label: 'Plastic Bags Used per Week',
          value: _i.plasticBagsWeek.toDouble(),
          min: 0, max: 30,
          divisions: 30,
          suffix: ' bags',
          onChanged: (v) => setState(() => _i.plasticBagsWeek = v.round()),
        ),
        const SizedBox(height: 20),
        SliderField(
          label: 'Water Bottles Bought per Month',
          value: _i.waterBottlesMonth.toDouble(),
          min: 0, max: 50,
          divisions: 50,
          suffix: ' bottles',
          onChanged: (v) => setState(() => _i.waterBottlesMonth = v.round()),
        ),
      ])),

      AppCard(child: NumberInputField(
        label: 'Monthly Shopping Spend (clothing, electronics, etc.)',
        prefix: '₹ ',
        value: _i.shoppingSpend,
        onChanged: (v) => setState(() => _i.shoppingSpend = v),
      )),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Home Composting', style: GoogleFonts.dmSans(
              fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
            )),
            Text('Saves ~80 kg CO₂e/year', style: GoogleFonts.dmSans(
              fontSize: 11, color: AppColors.textMuted,
            )),
          ])),
          Switch(
            value: _i.composting,
            onChanged: (v) => setState(() => _i.composting = v),
            activeColor: AppColors.greenDeep,
          ),
        ]),
      ])),

      NavButtons(
        onBack: widget.onBack,
        onNext: widget.onNext,
        nextLabel: '📊 Calculate Results',
        isLoading: widget.isLoading,
      ),
    ]),
  );
}
