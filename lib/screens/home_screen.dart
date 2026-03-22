// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      title: Row(children: [
        const Text('🌿 ', style: TextStyle(fontSize: 20)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mumbai Carbon', style: GoogleFonts.syne(
            fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white,
          )),
          Text('Footprint Calculator', style: GoogleFonts.dmSans(
            fontSize: 11, color: Colors.white.withOpacity(0.65),
          )),
        ]),
      ]),
    ),
    body: IndexedStack(index: _tab, children: const [
      CalculatorScreen(),
      HistoryScreen(),
    ]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.greenPale,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.calculate_outlined),
          selectedIcon: const Icon(Icons.calculate, color: AppColors.greenDeep),
          label: 'Calculator',
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history, color: AppColors.greenDeep),
          label: 'History',
        ),
      ],
    ),
  );
}
