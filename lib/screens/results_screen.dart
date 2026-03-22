// lib/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/emission_factors.dart';
import '../models/calculator_input.dart';
import '../utils/app_theme.dart';
import '../utils/carbon_calculator.dart';
import '../utils/history_service.dart';
import '../widgets/common_widgets.dart';

class ResultsScreen extends StatefulWidget {
  final CarbonResult result;
  final CalculatorInput input;
  final VoidCallback onRecalculate;
  const ResultsScreen({
    super.key, required this.result,
    required this.input, required this.onRecalculate,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  final _screenshotCtrl = ScreenshotController();
  bool _saved = false;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _autoSave();
  }

  Future<void> _autoSave() async {
    await HistoryService.save(widget.result);
    if (mounted) setState(() => _saved = true);
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  Future<void> _share() async {
    try {
      final image = await _screenshotCtrl.capture(pixelRatio: 2.0);
      if (image == null) return;
      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/carbon_report.png');
      await file.writeAsBytes(image);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Mumbai Household Carbon Footprint: ${widget.result.total.toStringAsFixed(2)} tonnes CO₂e/year\n\nCalculated with Mumbai Carbon Footprint Calculator 🌿',
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share. Please try again.')),
      );
    }
  }

  Color _ratingColor(String r) => switch (r) {
    'Excellent' => AppColors.greenAccent,
    'Good'      => AppColors.greenMid,
    'Average'   => AppColors.amber,
    _           => AppColors.red,
  };

  @override
  Widget build(BuildContext context) {
    final r    = widget.result;
    final tips = CarbonCalculator.generateTips(widget.input, r);
    final cats = [
      _Cat('Energy',    r.energyCO2,    AppColors.energyColor,    '⚡'),
      _Cat('Transport', r.transportCO2, AppColors.transportColor, '🚗'),
      _Cat('Food',      r.foodCO2,      AppColors.foodColor,      '🥗'),
      _Cat('Waste',     r.wasteCO2,     AppColors.wasteColor,     '🗑'),
    ];

    return FadeTransition(
      opacity: _fadeAnim,
      child: Screenshot(
        controller: _screenshotCtrl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── HERO TOTAL CARD ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.greenDeep,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Annual CO₂ Equivalent', style: GoogleFonts.dmSans(
                  fontSize: 12, letterSpacing: 1.2,
                  color: Colors.white.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 6),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(r.total.toStringAsFixed(2), style: GoogleFonts.syne(
                    fontSize: 48, fontWeight: FontWeight.w800,
                    color: AppColors.greenAccent, height: 1,
                  )),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('tonnes CO₂e/yr', style: GoogleFonts.dmSans(
                      fontSize: 13, color: Colors.white.withOpacity(0.6),
                    )),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _ratingColor(r.rating).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _ratingColor(r.rating).withOpacity(0.4)),
                    ),
                    child: Text('${r.ratingEmoji} ${r.rating}', style: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _ratingColor(r.rating),
                    )),
                  ),
                ]),
                const SizedBox(height: 16),
                _BenchmarkRow(label: 'India avg (per capita)', value: '1.9 t', icon: '🇮🇳'),
                const SizedBox(height: 4),
                _BenchmarkRow(label: 'Global avg (per capita)', value: '4.7 t', icon: '🌍'),
                const SizedBox(height: 4),
                _BenchmarkRow(label: 'Paris target', value: '2.0 t by 2050', icon: '🎯'),
              ]),
            ),

            const SizedBox(height: 16),

            // ── METRIC BADGES ────────────────────────────────────
            Row(children: [
              Expanded(child: _MetricCard(
                label: 'Per Capita',
                value: '${r.perCapita.toStringAsFixed(2)} t',
                sub: 'CO₂e/person/yr',
              )),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(
                label: 'vs India Avg',
                value: _vsIndia(r.perCapita),
                sub: 'India avg = 1.9 t',
                valueColor: _vsColor(r.perCapita),
              )),
            ]),

            const SizedBox(height: 8),

            // ── BREAKDOWN BARS ───────────────────────────────────
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Emissions Breakdown', style: GoogleFonts.syne(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
              )),
              const SizedBox(height: 16),
              ...cats.map((c) => _BreakdownBar(cat: c, total: r.total)),
            ])),

            // ── DONUT CHART ───────────────────────────────────────
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Category Share', style: GoogleFonts.syne(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
              )),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, resp) {
                            setState(() {
                              _touchedIndex = resp?.touchedSection?.touchedSectionIndex ?? -1;
                            });
                          },
                        ),
                        sectionsSpace: 3,
                        centerSpaceRadius: 48,
                        sections: cats.asMap().entries.map((e) {
                          final touched = e.key == _touchedIndex;
                          final pct = r.total > 0 ? (e.value.value / r.total * 100) : 0.0;
                          return PieChartSectionData(
                            value: e.value.value,
                            color: e.value.color,
                            radius: touched ? 70 : 60,
                            showTitle: touched,
                            title: touched ? '${pct.toStringAsFixed(1)}%' : '',
                            titleStyle: GoogleFonts.syne(
                              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cats.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(
                            color: c.color, borderRadius: BorderRadius.circular(3),
                          )),
                          const SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c.label, style: GoogleFonts.dmSans(
                              fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMid,
                            )),
                            Text('${c.value.toStringAsFixed(2)} t', style: GoogleFonts.syne(
                              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
                            )),
                          ])),
                        ]),
                      )).toList(),
                    ),
                  ),
                ]),
              ),
            ])),

            // ── BAR CHART (category comparison) ─────────────────
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Category Comparison', style: GoogleFonts.syne(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
              )),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: cats.map((c) => c.value).reduce((a, b) => a > b ? a : b) * 1.3,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final labels = ['Energy', 'Transport', 'Food', 'Waste'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[v.toInt()], style: GoogleFonts.dmSans(
                                fontSize: 10, color: AppColors.textMuted,
                              )),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: AppColors.border, strokeWidth: 0.5,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: cats.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(
                        toY: e.value.value,
                        color: e.value.color,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true, toY: cats.map((c) => c.value).reduce((a, b) => a > b ? a : b) * 1.3,
                          color: AppColors.border.withOpacity(0.1),
                        ),
                      )],
                    )).toList(),
                  ),
                ),
              ),
            ])),

            // ── TIPS ─────────────────────────────────────────────
            Text('🌱 Tips to Reduce Your Footprint', style: GoogleFonts.syne(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
            )),
            const SizedBox(height: 12),
            ...tips.map((tip) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(
                  color: AppColors.greenDeep.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2),
                )],
              ),
              child: Text(tip, style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.textMid, height: 1.55,
              )),
            )),

            const SizedBox(height: 24),

            // ── ACTION BUTTONS ────────────────────────────────────
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share Report'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenMid),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRecalculate,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Recalculate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.greenDeep,
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),

            if (_saved) ...[
              const SizedBox(height: 12),
              Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.greenAccent),
                const SizedBox(width: 6),
                Text('Result saved to history', style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.textMuted,
                )),
              ])),
            ],

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  String _vsIndia(double perCap) {
    final pct = ((perCap - CarbonResult.indiaAvg) / CarbonResult.indiaAvg * 100).round();
    if (pct.abs() < 5) return 'Near avg';
    return pct < 0 ? '${pct.abs()}% below' : '+$pct% above';
  }

  Color _vsColor(double perCap) {
    final pct = (perCap - CarbonResult.indiaAvg) / CarbonResult.indiaAvg * 100;
    if (pct < -5) return AppColors.greenAccent;
    if (pct < 20) return AppColors.amber;
    return AppColors.red;
  }
}

class _Cat {
  final String label; final double value; final Color color; final String icon;
  const _Cat(this.label, this.value, this.color, this.icon);
}

class _BenchmarkRow extends StatelessWidget {
  final String label, value, icon;
  const _BenchmarkRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(icon, style: const TextStyle(fontSize: 12)),
    const SizedBox(width: 6),
    Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.6))),
    const Spacer(),
    Text(value, style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
  ]);
}

class _MetricCard extends StatelessWidget {
  final String label, value, sub;
  final Color? valueColor;
  const _MetricCard({required this.label, required this.value, required this.sub, this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.syne(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: valueColor ?? AppColors.greenDeep,
      )),
      Text(sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
    ]),
  );
}

class _BreakdownBar extends StatelessWidget {
  final _Cat cat;
  final double total;
  const _BreakdownBar({required this.cat, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? cat.value / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(children: [
        Row(children: [
          Text(cat.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(cat.label, style: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMid,
          ))),
          Text('${cat.value.toStringAsFixed(2)} t', style: GoogleFonts.syne(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
          )),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v, minHeight: 8,
              backgroundColor: AppColors.greenPale,
              valueColor: AlwaysStoppedAnimation(cat.color),
            ),
          ),
        ),
      ]),
    );
  }
}
