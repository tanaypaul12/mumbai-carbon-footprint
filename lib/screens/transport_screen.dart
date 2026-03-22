// lib/screens/transport_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_input.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class TransportScreen extends StatefulWidget {
  final CalculatorInput input;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const TransportScreen({super.key, required this.input, required this.onBack, required this.onNext});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  late CalculatorInput _i;

  final _modes = [
    _Mode('walk',   '🚶', 'Walk / Cycle'),
    _Mode('local',  '🚉', 'Mumbai Local'),
    _Mode('bus',    '🚌', 'BEST / Metro'),
    _Mode('auto',   '🛺', 'Auto Rickshaw'),
    _Mode('taxi',   '🚕', 'Cab (Ola/Uber)'),
    _Mode('bike',   '🏍️', 'Two-Wheeler'),
    _Mode('car',    '🚗', 'Personal Car'),
    _Mode('ev',     '⚡', 'Electric Vehicle'),
  ];

  @override
  void initState() { super.initState(); _i = widget.input; }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(icon: '🚗', title: 'Transport & Commute'),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Primary Commute Mode', style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
        )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _modes.map((m) {
            final sel = _i.commuteMode == m.value;
            return GestureDetector(
              onTap: () => setState(() => _i.commuteMode = m.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.greenDeep : AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? AppColors.greenDeep : AppColors.border, width: 1.5,
                  ),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(m.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(m.label, style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: sel ? Colors.white : AppColors.textMid,
                  )),
                ]),
              ),
            );
          }).toList(),
        ),
      ])),

      AppCard(child: SliderField(
        label: 'Daily Commute Distance (one-way)',
        value: _i.commuteDist,
        min: 0, max: 50,
        divisions: 50,
        suffix: ' km',
        onChanged: (v) => setState(() => _i.commuteDist = v),
      )),

      AppCard(child: Column(children: [
        NumberInputField(
          label: 'Personal Car km/month (extra)',
          suffix: ' km',
          hint: 'Weekends, errands',
          value: _i.carKmMonth,
          onChanged: (v) => setState(() => _i.carKmMonth = v),
        ),
        const SizedBox(height: 16),
        NumberInputField(
          label: 'Two-Wheeler km/month (extra)',
          suffix: ' km',
          value: _i.bikeKmMonth,
          onChanged: (v) => setState(() => _i.bikeKmMonth = v),
        ),
      ])),

      AppCard(child: Column(children: [
        SliderField(
          label: 'Domestic Flights per Year',
          value: _i.domFlights.toDouble(),
          min: 0, max: 20,
          divisions: 20,
          suffix: ' trips',
          onChanged: (v) => setState(() => _i.domFlights = v.round()),
        ),
        const SizedBox(height: 8),
        Text('Return trips. ~255 kg CO₂e each.', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 20),
        SliderField(
          label: 'International Flights per Year',
          value: _i.intlFlights.toDouble(),
          min: 0, max: 10,
          divisions: 10,
          suffix: ' trips',
          onChanged: (v) => setState(() => _i.intlFlights = v.round()),
        ),
        const SizedBox(height: 8),
        Text('Return trips. ~1,100 kg CO₂e each.', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
      ])),

      NavButtons(onBack: widget.onBack, onNext: widget.onNext, nextLabel: 'Food →'),
    ]),
  );
}

class _Mode {
  final String value, emoji, label;
  const _Mode(this.value, this.emoji, this.label);
}
