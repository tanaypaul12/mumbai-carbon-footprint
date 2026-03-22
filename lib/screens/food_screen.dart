// lib/screens/food_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_input.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class FoodScreen extends StatefulWidget {
  final CalculatorInput input;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const FoodScreen({super.key, required this.input, required this.onBack, required this.onNext});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late CalculatorInput _i;

  @override
  void initState() { super.initState(); _i = widget.input; }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(icon: '🥗', title: 'Food & Diet'),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Diet Type (per person in household)', style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
        )),
        const SizedBox(height: 12),
        ChipSelector<String>(
          selected: _i.dietType,
          onChanged: (v) => setState(() => _i.dietType = v),
          options: const [
            ChipOption(value: 'vegan',       label: '🌱 Vegan'),
            ChipOption(value: 'veg',         label: '🥦 Vegetarian'),
            ChipOption(value: 'eggetarian',  label: '🥚 Eggetarian'),
            ChipOption(value: 'nonveg_low',  label: '🍗 Non-veg 1-2×/wk'),
            ChipOption(value: 'nonveg_high', label: '🥩 Non-veg daily'),
          ],
        ),
        const SizedBox(height: 12),
        _DietImpactBar(selected: _i.dietType),
      ])),

      AppCard(child: Column(children: [
        NumberInputField(
          label: 'Monthly Grocery Spend',
          prefix: '₹ ',
          hint: 'Entire household',
          value: _i.grocerySpend,
          onChanged: (v) => setState(() => _i.grocerySpend = v),
        ),
        const SizedBox(height: 16),
        NumberInputField(
          label: 'Monthly Eating Out / Ordering Spend',
          prefix: '₹ ',
          hint: 'Zomato, Swiggy, restaurants',
          value: _i.diningSpend,
          onChanged: (v) => setState(() => _i.diningSpend = v),
        ),
      ])),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Food Waste Level', style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
        )),
        const SizedBox(height: 12),
        ChipSelector<String>(
          selected: _i.foodWaste,
          onChanged: (v) => setState(() => _i.foodWaste = v),
          options: const [
            ChipOption(value: 'low',    label: 'Low — very little wasted'),
            ChipOption(value: 'medium', label: 'Medium — some waste daily'),
            ChipOption(value: 'high',   label: 'High — significant waste'),
          ],
        ),
      ])),

      NavButtons(onBack: widget.onBack, onNext: widget.onNext, nextLabel: 'Waste →'),
    ]),
  );
}

class _DietImpactBar extends StatelessWidget {
  final String selected;
  const _DietImpactBar({required this.selected});

  static const _impacts = {
    'vegan': 0.20, 'veg': 0.33, 'eggetarian': 0.47,
    'nonveg_low': 0.67, 'nonveg_high': 1.0,
  };
  static const _labels = {
    'vegan': '1.5 t CO₂e/yr', 'veg': '2.5 t', 'eggetarian': '3.5 t',
    'nonveg_low': '5.0 t', 'nonveg_high': '7.5 t',
  };

  @override
  Widget build(BuildContext context) {
    final frac = _impacts[selected] ?? 0.33;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Diet carbon impact:', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
        Text(_labels[selected] ?? '', style: GoogleFonts.syne(
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
        )),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: frac,
          minHeight: 6,
          backgroundColor: AppColors.greenPale,
          valueColor: AlwaysStoppedAnimation(
            frac < 0.4 ? AppColors.greenAccent : frac < 0.7 ? AppColors.amber : AppColors.red,
          ),
        ),
      ),
    ]);
  }
}
