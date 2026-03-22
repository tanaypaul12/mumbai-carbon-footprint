// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.greenDeep,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MumbaiCarbonApp());
}

class MumbaiCarbonApp extends StatelessWidget {
  const MumbaiCarbonApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mumbai Carbon Footprint',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: const HomeScreen(),
  );
}
