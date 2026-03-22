// lib/models/emission_factors.dart
// Mumbai-calibrated emission factors based on:
// Maharashtra SERC grid intensity, MoPNG LPG data, IPCC food emission factors

class EmissionFactors {
  // ── ENERGY ───────────────────────────────────────────────────
  static const double electricityPerKwh = 0.82;   // kg CO2e/kWh (Maharashtra grid)
  static const double mumbaiElecTariff  = 5.50;   // ₹ per kWh (avg MSEDCL domestic)
  static const double lpgPerKg          = 2.983;  // kg CO2e / kg LPG
  static const double lpgCylWeight      = 14.2;   // kg per 14.2 kg cylinder
  static const double pngPerSCM         = 2.03;   // kg CO2e / standard cubic metre
  static const double pngRatePerSCM     = 32.0;   // ₹ per SCM (MGL Mumbai rate)

  // AC seasonal multipliers (additional fraction of elec bill)
  static const Map<int, double> acFactor = {
    0: 0.00,  // No AC
    1: 0.08,  // 1-2 months/yr
    2: 0.18,  // 3-5 months/yr
    3: 0.35,  // 6+ months/yr (year-round Mumbai summers)
  };

  // ── TRANSPORT kg CO2e / km ────────────────────────────────────
  static const Map<String, double> transportEF = {
    'walk':   0.000,
    'local':  0.030,  // Mumbai Local Train (electric, shared)
    'bus':    0.050,  // BEST Bus / Metro
    'auto':   0.090,  // CNG Auto Rickshaw
    'taxi':   0.150,  // Cab (Ola/Uber - mostly petrol/CNG)
    'bike':   0.080,  // Two-wheeler (avg petrol)
    'car':    0.170,  // Personal car (petrol sedan)
    'ev':     0.040,  // Electric vehicle (Maharashtra grid)
  };

  // Flight emissions (return trip, includes radiative forcing)
  static const double domFlightKg   = 255.0;   // kg CO2e per return domestic flight
  static const double intlFlightKg  = 1100.0;  // kg CO2e per return short-haul international

  // ── FOOD kg CO2e / person / day ───────────────────────────────
  static const Map<String, double> dietEF = {
    'vegan':       1.50,
    'veg':         2.50,
    'eggetarian':  3.50,
    'nonveg_low':  5.00,  // 1-2 times/week
    'nonveg_high': 7.50,  // daily meat consumption
  };

  // Embedded carbon in spending (kg CO2e per ₹1000)
  static const double groceryFactor = 0.50;
  static const double diningFactor  = 0.65;

  // Additional food waste emissions (kg CO2e / year)
  static const Map<String, double> foodWasteEF = {
    'low':    0.0,
    'medium': 80.0,
    'high':   250.0,
  };

  // ── WASTE & CONSUMPTION ───────────────────────────────────────
  static const double plasticBagKg   = 0.040;  // kg CO2e per plastic bag
  static const double waterBottleKg  = 0.210;  // kg CO2e per 1L PET bottle
  static const double shoppingFactor = 0.350;  // kg CO2e per ₹1000

  // Waste segregation benefit (kg CO2e saved / year)
  static const Map<String, double> wasteSegSaving = {
    'none': 0.0,
    'some': 50.0,
    'full': 150.0,
  };

  static const double compostingBonus = 80.0; // kg CO2e saved / year
}

class CarbonResult {
  final double energyCO2;
  final double transportCO2;
  final double foodCO2;
  final double wasteCO2;
  final int members;
  final DateTime calculatedAt;
  final String id;

  CarbonResult({
    required this.energyCO2,
    required this.transportCO2,
    required this.foodCO2,
    required this.wasteCO2,
    required this.members,
    required this.calculatedAt,
    required this.id,
  });

  double get total => energyCO2 + transportCO2 + foodCO2 + wasteCO2;
  double get perCapita => total / members;

  // Benchmarks
  static const double indiaAvg  = 1.9;  // tonnes CO2e/person/yr
  static const double globalAvg = 4.7;
  static const double parisTarget = 2.0;

  String get rating {
    if (perCapita < 1.5) return 'Excellent';
    if (perCapita < 3.0) return 'Good';
    if (perCapita < 5.0) return 'Average';
    return 'High';
  }

  String get ratingEmoji {
    if (perCapita < 1.5) return '🌟';
    if (perCapita < 3.0) return '👍';
    if (perCapita < 5.0) return '⚠️';
    return '❗';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'energyCO2': energyCO2,
    'transportCO2': transportCO2,
    'foodCO2': foodCO2,
    'wasteCO2': wasteCO2,
    'members': members,
    'calculatedAt': calculatedAt.toIso8601String(),
  };

  factory CarbonResult.fromJson(Map<String, dynamic> json) => CarbonResult(
    id: json['id'] ?? '',
    energyCO2: (json['energyCO2'] ?? 0).toDouble(),
    transportCO2: (json['transportCO2'] ?? 0).toDouble(),
    foodCO2: (json['foodCO2'] ?? 0).toDouble(),
    wasteCO2: (json['wasteCO2'] ?? 0).toDouble(),
    members: json['members'] ?? 1,
    calculatedAt: DateTime.parse(json['calculatedAt'] ?? DateTime.now().toIso8601String()),
  );
}
