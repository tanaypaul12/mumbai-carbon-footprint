// lib/models/calculator_input.dart

class CalculatorInput {
  // ── ENERGY ──────────────────────────────────────────────
  double electricityBill;   // ₹/month
  double lpgCylinders;      // cylinders/month
  double pngBill;           // ₹/month
  int    householdMembers;
  int    acUsage;           // 0=none,1=1-2mo,2=3-5mo,3=6+mo

  // ── TRANSPORT ────────────────────────────────────────────
  String commuteMode;
  double commuteDist;       // km one-way
  double carKmMonth;        // extra car km/month
  double bikeKmMonth;       // extra bike km/month
  int    domFlights;        // return trips/year
  int    intlFlights;       // return trips/year

  // ── FOOD ─────────────────────────────────────────────────
  String dietType;
  double grocerySpend;      // ₹/month
  double diningSpend;       // ₹/month
  String foodWaste;         // low/medium/high

  // ── WASTE ────────────────────────────────────────────────
  String wasteSeg;          // none/some/full
  int    plasticBagsWeek;
  int    waterBottlesMonth;
  double shoppingSpend;     // ₹/month
  bool   composting;

  CalculatorInput({
    this.electricityBill   = 1500,
    this.lpgCylinders      = 1.0,
    this.pngBill           = 0,
    this.householdMembers  = 4,
    this.acUsage           = 0,
    this.commuteMode       = 'bus',
    this.commuteDist       = 12,
    this.carKmMonth        = 0,
    this.bikeKmMonth       = 0,
    this.domFlights        = 2,
    this.intlFlights       = 0,
    this.dietType          = 'veg',
    this.grocerySpend      = 6000,
    this.diningSpend       = 2000,
    this.foodWaste         = 'medium',
    this.wasteSeg          = 'some',
    this.plasticBagsWeek   = 5,
    this.waterBottlesMonth = 4,
    this.shoppingSpend     = 3000,
    this.composting        = false,
  });
}
