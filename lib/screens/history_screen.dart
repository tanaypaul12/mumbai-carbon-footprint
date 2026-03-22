// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/emission_factors.dart';
import '../utils/app_theme.dart';
import '../utils/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CarbonResult> _history = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final h = await HistoryService.load();
    setState(() { _history = h; _loading = false; });
  }

  Future<void> _delete(String id) async {
    await HistoryService.delete(id);
    await _load();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Clear History', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Text('Delete all saved calculations?', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.clear();
      await _load();
    }
  }

  Color _ratingColor(String r) => switch (r) {
    'Excellent' => AppColors.greenAccent,
    'Good'      => AppColors.greenMid,
    'Average'   => AppColors.amber,
    _           => AppColors.red,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      title: const Text('Calculation History'),
      actions: [
        if (_history.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearAll,
            tooltip: 'Clear all',
          ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.greenDeep))
        : _history.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('📊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text('No calculations yet', style: GoogleFonts.syne(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMid,
                )),
                const SizedBox(height: 8),
                Text('Your results will appear here after calculating', style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textMuted,
                )),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (_, i) {
                  final r = _history[i];
                  return Dismissible(
                    key: Key(r.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.red),
                    ),
                    onDismissed: (_) => _delete(r.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(
                          color: AppColors.greenDeep.withOpacity(0.05),
                          blurRadius: 12, offset: const Offset(0, 3),
                        )],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        leading: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: _ratingColor(r.rating).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(r.ratingEmoji, style: const TextStyle(fontSize: 22))),
                        ),
                        title: Row(children: [
                          Text('${r.total.toStringAsFixed(2)} t CO₂e', style: GoogleFonts.syne(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
                          )),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _ratingColor(r.rating).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(r.rating, style: GoogleFonts.dmSans(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: _ratingColor(r.rating),
                            )),
                          ),
                        ]),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: 4),
                          Text(
                            '${r.members} members · ${r.perCapita.toStringAsFixed(2)} t per person',
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(r.calculatedAt),
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            _MiniBar('⚡', r.energyCO2,    AppColors.energyColor,    r.total),
                            const SizedBox(width: 4),
                            _MiniBar('🚗', r.transportCO2, AppColors.transportColor, r.total),
                            const SizedBox(width: 4),
                            _MiniBar('🥗', r.foodCO2,      AppColors.foodColor,      r.total),
                            const SizedBox(width: 4),
                            _MiniBar('🗑', r.wasteCO2,     AppColors.wasteColor,     r.total),
                          ]),
                        ]),
                      ),
                    ),
                  );
                },
              ),
  );
}

class _MiniBar extends StatelessWidget {
  final String icon;
  final double value, total;
  final Color color;
  const _MiniBar(this.icon, this.value, this.color, this.total);

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? value / total : 0.0;
    return Expanded(
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct, minHeight: 4,
            backgroundColor: AppColors.greenPale,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }
}
