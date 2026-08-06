import "package:flutter/material.dart";
import "../theme/app_theme.dart";

class SimpleBarChart extends StatelessWidget {
  final List<MapEntry<String, int>> data;
  final Color color;
  const SimpleBarChart({super.key, required this.data, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty ? 1 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b).clamp(1, 999999);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: data.map((e) {
          final ratio = e.value / maxVal;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(width: 78, child: Text(e.key, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 16, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8))),
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        widthFactor: ratio.clamp(0.03, 1.0),
                        child: Container(height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(width: 24, child: Text("${e.value}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
