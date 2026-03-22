// lib/utils/history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emission_factors.dart';

class HistoryService {
  static const _key = 'carbon_history';

  static Future<List<CarbonResult>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_key) ?? [];
    return raw.map((s) => CarbonResult.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
  }

  static Future<void> save(CarbonResult result) async {
    final prefs   = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.add(jsonEncode(result.toJson()));
    // Keep last 20 results
    if (current.length > 20) current.removeAt(0);
    await prefs.setStringList(_key, current);
  }

  static Future<void> delete(String id) async {
    final prefs   = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.removeWhere((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m['id'] == id;
    });
    await prefs.setStringList(_key, current);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
