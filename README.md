# 🌿 Mumbai Carbon Footprint Calculator — Android App

A beautiful, fully-featured Flutter Android app for calculating household carbon footprints, calibrated specifically for Mumbai residents.

---

## 📱 Features

| Feature | Details |
|---|---|
| **4-Step Calculator** | Energy → Transport → Food → Waste |
| **Mumbai-Calibrated EFs** | Maharashtra SERC grid (0.82 kg CO₂e/kWh), MGL PNG rates, MSEDCL tariffs |
| **Charts & Visuals** | Animated donut chart, bar chart, breakdown bars |
| **Results History** | Auto-saved, swipe-to-delete, persistent storage |
| **Share Report** | Screenshot-to-image, native Android share sheet |
| **Personalised Tips** | 5 Mumbai-specific reduction tips per calculation |

---

## 🚀 Setup & Installation

### Prerequisites

| Tool | Version | Download |
|---|---|---|
| Flutter SDK | ≥ 3.0.0 | https://flutter.dev/docs/get-started/install |
| Android Studio | Latest | https://developer.android.com/studio |
| Java JDK | 11 or 17 | Bundled with Android Studio |
| Android SDK | API 21+ | Via Android Studio SDK Manager |

### Step 1 — Clone / Copy the project

```bash
# If using git
git clone <your-repo-url>
cd mumbai_carbon_footprint

# Or just navigate to the folder
cd mumbai_carbon_footprint
```

### Step 2 — Install dependencies

```bash
flutter pub get
```

### Step 3 — Run on device/emulator

```bash
# List available devices
flutter devices

# Run in debug mode
flutter run

# Run on a specific device
flutter run -d <device-id>
```

### Step 4 — Build release APK

```bash
# Build APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry, theme setup
├── models/
│   ├── emission_factors.dart        # Mumbai EFs + CarbonResult model
│   └── calculator_input.dart        # All user inputs in one model
├── utils/
│   ├── carbon_calculator.dart       # Calculation engine + tips generator
│   ├── history_service.dart         # SharedPreferences persistence layer
│   └── app_theme.dart               # Colors, typography (Syne + DM Sans)
├── widgets/
│   └── common_widgets.dart          # Shared UI: chips, sliders, cards, nav
└── screens/
    ├── home_screen.dart             # Bottom nav shell
    ├── calculator_screen.dart       # 5-step wizard + animated transitions
    ├── energy_screen.dart           # Step 1: electricity, LPG, PNG, AC
    ├── transport_screen.dart        # Step 2: 8 commute modes + flights
    ├── food_screen.dart             # Step 3: diet, grocery, food waste
    ├── waste_screen.dart            # Step 4: segregation, plastic, shopping
    └── results_screen.dart          # Charts, breakdown, tips, share
```

---

## 🔬 Emission Factors Used

All factors are Mumbai/Maharashtra-specific:

### Energy
| Source | Factor | Reference |
|---|---|---|
| Electricity | 0.82 kg CO₂e/kWh | Maharashtra SERC grid intensity |
| LPG | 2.983 kg CO₂e/kg | MoPNG / IPCC |
| PNG (piped gas) | 2.03 kg CO₂e/SCM | MGL Mumbai rate ₹32/SCM |

### Transport (kg CO₂e/km/passenger)
| Mode | Factor |
|---|---|
| Walk/Cycle | 0.000 |
| Mumbai Local (electric) | 0.030 |
| BEST Bus / Metro | 0.050 |
| CNG Auto Rickshaw | 0.090 |
| Cab (Ola/Uber) | 0.150 |
| Two-Wheeler (petrol) | 0.080 |
| Personal Car | 0.170 |
| Electric Vehicle | 0.040 |

### Flights
| Type | Factor |
|---|---|
| Domestic (return) | 255 kg CO₂e |
| International (return) | 1,100 kg CO₂e |

### Diet (kg CO₂e/person/day)
| Diet | Factor |
|---|---|
| Vegan | 1.50 |
| Vegetarian | 2.50 |
| Eggetarian | 3.50 |
| Non-veg (1–2×/week) | 5.00 |
| Non-veg (daily) | 7.50 |

---

## 📦 Dependencies

```yaml
fl_chart: ^0.68.0          # Donut + bar charts
shared_preferences: ^2.2.3  # History persistence
share_plus: ^9.0.0          # Native Android sharing
screenshot: ^3.0.0          # Capture results as image
intl: ^0.19.0               # Date formatting
google_fonts: ^6.2.1        # Syne + DM Sans fonts
flutter_animate: ^4.5.0     # Smooth animations
path_provider: ^2.1.4       # Temp file storage for sharing
uuid: ^4.4.0                # Unique IDs for history records
```

---

## 🎨 Design System

- **Primary font**: Syne (headings, numbers) — geometric, bold
- **Body font**: DM Sans — clean, readable
- **Primary color**: `#0A3B2E` (deep forest green)
- **Accent**: `#2FC87A` (vivid green)
- **Min Android SDK**: API 21 (Android 5.0 Lollipop)
- **Target SDK**: Latest stable

---

## 🌍 Benchmarks Used

| Benchmark | Value |
|---|---|
| India average (per capita) | 1.9 t CO₂e/yr |
| Global average (per capita) | 4.7 t CO₂e/yr |
| Paris Agreement target | 2.0 t CO₂e/yr by 2050 |

---

## 🔧 Troubleshooting

**`flutter pub get` fails**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Android build fails with SDK error**
```bash
flutter doctor -v
# Fix any issues shown, especially Android SDK and licenses
flutter doctor --android-licenses
```

**Google Fonts not loading (offline)**
The app uses `google_fonts` which caches fonts after first use. Ensure internet access on first launch, or bundle fonts locally.

**Share not working on emulator**
The share feature requires a physical device or an emulator with Google Play installed.

---

## 📄 License

MIT License — free to use, modify, and distribute.
