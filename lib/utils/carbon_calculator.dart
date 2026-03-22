// lib/utils/carbon_calculator.dart
import 'package:uuid/uuid.dart';
import '../models/calculator_input.dart';
import '../models/emission_factors.dart';

class CarbonCalculator {
  static CarbonResult calculate(CalculatorInput inp) {
    // ── ENERGY (tonnes CO2e / year) ──────────────────────────
    final kwhMonth  = inp.electricityBill / EmissionFactors.mumbaiElecTariff;
    final elecBase  = kwhMonth * 12 * EmissionFactors.electricityPerKwh / 1000;
    final acBonus   = elecBase * (EmissionFactors.acFactor[inp.acUsage] ?? 0);
    final lpg       = inp.lpgCylinders * 12 * EmissionFactors.lpgCylWeight * EmissionFactors.lpgPerKg / 1000;
    final png       = inp.pngBill * 12 / EmissionFactors.pngRatePerSCM * EmissionFactors.pngPerSCM / 1000;
    final energy    = elecBase + acBonus + lpg + png;

    // ── TRANSPORT (tonnes CO2e / year) ───────────────────────
    final modeEF    = EmissionFactors.transportEF[inp.commuteMode] ?? 0.05;
    final commute   = inp.commuteDist * 2 * 22 * 12 * modeEF / 1000;
    final car       = inp.carKmMonth * 12 * EmissionFactors.transportEF['car']! / 1000;
    final bike      = inp.bikeKmMonth * 12 * EmissionFactors.transportEF['bike']! / 1000;
    final flights   = (inp.domFlights  * EmissionFactors.domFlightKg +
                       inp.intlFlights * EmissionFactors.intlFlightKg) / 1000;
    final transport = commute + car + bike + flights;

    // ── FOOD (tonnes CO2e / year) ────────────────────────────
    final dietEF    = EmissionFactors.dietEF[inp.dietType] ?? 2.5;
    final diet      = inp.householdMembers * dietEF * 365 / 1000;
    final grocery   = inp.grocerySpend * 12 * EmissionFactors.groceryFactor / 1000;
    final dining    = inp.diningSpend  * 12 * EmissionFactors.diningFactor  / 1000;
    final fwaste    = (EmissionFactors.foodWasteEF[inp.foodWaste] ?? 80) / 1000;
    final food      = diet + grocery + dining + fwaste;

    // ── WASTE & CONSUMPTION (tonnes CO2e / year) ─────────────
    final plastic   = inp.plasticBagsWeek   * 52 * EmissionFactors.plasticBagKg  / 1000;
    final bottles   = inp.waterBottlesMonth * 12 * EmissionFactors.waterBottleKg / 1000;
    final shopping  = inp.shoppingSpend * 12 * EmissionFactors.shoppingFactor    / 1000;
    final segSave   = (EmissionFactors.wasteSegSaving[inp.wasteSeg] ?? 0)        / 1000;
    final compSave  = inp.composting ? EmissionFactors.compostingBonus / 1000 : 0;
    final waste     = (plastic + bottles + shopping - segSave - compSave).clamp(0, double.infinity);

    return CarbonResult(
      energyCO2:    _round(energy),
      transportCO2: _round(transport),
      foodCO2:      _round(food),
      wasteCO2:     _round(waste),
      members:      inp.householdMembers,
      calculatedAt: DateTime.now(),
      id:           const Uuid().v4(),
    );
  }

  static double _round(double v) => double.parse(v.toStringAsFixed(3));

  static List<String> generateTips(CalculatorInput inp, CarbonResult res) {
    final tips = <String>[];
    final cats = {
      'energy':    res.energyCO2,
      'transport': res.transportCO2,
      'food':      res.foodCO2,
      'waste':     res.wasteCO2,
    };
    final biggest = cats.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    if (biggest == 'energy' || res.energyCO2 > 1.5) {
      tips.add('💡 Switch to LED bulbs throughout your home. Mumbai residents save 200–400 kg CO₂/year this way.');
      tips.add('☀️ Consider MSEDCL\'s rooftop solar net-metering scheme. A 2kW system can offset up to 60% of typical electricity use.');
    }
    if (inp.acUsage >= 2) {
      tips.add('❄️ Set your AC to 24°C instead of 18°C — each degree higher saves ~6% electricity. Use ceiling fans alongside AC.');
    }
    if (biggest == 'transport' || res.transportCO2 > 1.5) {
      if (inp.commuteMode == 'car') {
        tips.add('🚉 Switch your commute to Mumbai Local or Metro for 3 days/week — this alone can cut transport emissions by 30–40%.');
      }
      if (inp.domFlights > 3) {
        tips.add('✈️ Take trains instead of flights for routes under 600 km (Pune, Ahmedabad, Goa). A train emits ~90% less CO₂ than a flight.');
      }
      tips.add('🚲 For distances under 3 km, walking or cycling emits zero carbon and improves health.');
    }
    if (inp.dietType == 'nonveg_high' || inp.dietType == 'nonveg_low') {
      tips.add('🥗 Eat meat-free 3 days/week. Shifting to a vegetarian diet cuts food emissions by ~50%, saving over 1 tonne CO₂e/year per person.');
    }
    if (inp.wasteSeg != 'full') {
      tips.add('♻️ Fully segregate your dry and wet waste. BMC\'s SWaCH program collects segregated waste — composting wet waste diverts 60% from landfills.');
    }
    if (!inp.composting) {
      tips.add('🌱 Start home composting with a simple pot composter. Wet kitchen waste composted at home saves ~80 kg CO₂e per year.');
    }
    if (inp.plasticBagsWeek > 3) {
      tips.add('🛍️ Carry a cloth bag always. Eliminating single-use plastic saves ~20 kg CO₂e per person per year in Mumbai households.');
    }
    if (res.perCapita > 3) {
      tips.add('🌳 Offset what you can\'t yet reduce — platforms like GreenJams and Carbon Clean India offer certified Indian offsets including mangrove restoration near Mumbai.');
    }
    return tips.take(5).toList();
  }
}
