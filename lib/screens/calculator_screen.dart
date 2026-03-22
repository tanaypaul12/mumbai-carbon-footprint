// lib/screens/calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_input.dart';
import '../models/emission_factors.dart';
import '../utils/app_theme.dart';
import '../utils/carbon_calculator.dart';
import '../widgets/common_widgets.dart';
import 'energy_screen.dart';
import 'transport_screen.dart';
import 'food_screen.dart';
import 'waste_screen.dart';
import 'results_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int _step = 0;
  final _input = CalculatorInput();
  CarbonResult? _result;
  bool _calculating = false;

  static const _steps = ['Energy', 'Transport', 'Food', 'Waste', 'Results'];
  static const _stepIcons = ['⚡', '🚗', '🥗', '🗑', '📊'];

  void _next() {
    if (_step < 3) setState(() => _step++);
    else _calculate();
  }

  void _back() { if (_step > 0) setState(() => _step--); }

  Future<void> _calculate() async {
    setState(() => _calculating = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final result = CarbonCalculator.calculate(_input);
    setState(() { _result = result; _step = 4; _calculating = false; });
  }

  void _reset() => setState(() { _step = 0; _result = null; });

  @override
  Widget build(BuildContext context) => Column(children: [
    // Step bar
    Container(
      color: AppColors.greenDeep,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_steps.length, (i) {
            final isDone   = i < _step;
            final isActive = i == _step;
            return GestureDetector(
              onTap: () { if (isDone) setState(() => _step = i); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.greenAccent
                      : isDone
                          ? AppColors.greenMid
                          : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? Border.all(color: AppColors.greenAccent.withOpacity(0.5), width: 2) : null,
                ),
                child: Center(child: Text(_stepIcons[i], style: const TextStyle(fontSize: 16))),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_steps.length, (i) => SizedBox(
            width: 48,
            child: Text(_steps[i],
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: i == _step ? FontWeight.w600 : FontWeight.w400,
                color: i == _step ? AppColors.greenAccent : Colors.white.withOpacity(0.45),
              ),
            ),
          )),
        ),
        const SizedBox(height: 10),
        // Progress line
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: _step / (_steps.length - 1),
            minHeight: 3,
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation(AppColors.greenAccent),
          ),
        ),
      ]),
    ),

    // Step content
    Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: switch (_step) {
            0 => EnergyScreen(input: _input, onNext: _next),
            1 => TransportScreen(input: _input, onBack: _back, onNext: _next),
            2 => FoodScreen(input: _input, onBack: _back, onNext: _next),
            3 => WasteScreen(input: _input, onBack: _back, onNext: _next, isLoading: _calculating),
            4 => _result != null
                ? ResultsScreen(result: _result!, input: _input, onRecalculate: _reset)
                : const Center(child: CircularProgressIndicator(color: AppColors.greenDeep)),
            _ => const SizedBox(),
          },
        ),
      ),
    ),
  ]);
}
