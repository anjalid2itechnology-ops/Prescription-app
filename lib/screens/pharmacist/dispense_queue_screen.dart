import "package:flutter/material.dart";
import "../../models/prescription.dart";
import "../../services/inventory_service.dart";
import "../../services/prescription_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class DispenseQueueScreen extends StatefulWidget {
  final String pharmacistAtSign;
  const DispenseQueueScreen({super.key, required this.pharmacistAtSign});

  @override
  State<DispenseQueueScreen> createState() => _DispenseQueueScreenState();
}

class _DispenseQueueScreenState extends State<DispenseQueueScreen> {
  final _prescriptionService = PrescriptionService();
  final _inventoryService = InventoryService();
  late Future<List<Prescription>> _future;

  @override
  void initState() {
    super.initState();
    _future = _prescriptionService.getDispenseQueue(widget.pharmacistAtSign);
  }

  void _refresh() => setState(() => _future = _prescriptionService.getDispenseQueue(widget.pharmacistAtSign));

  Future<void> _dispense(Prescription p) async {
    await _prescriptionService.markDispensed(p);
    await _inventoryService.reduceStockForPrescription(p);
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Marked \"${p.diagnosis}\" as dispensed.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Prescription>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoading();
          final list = snapshot.data!;
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.task_alt_rounded,
              message: "Queue is empty. New prescriptions from doctors\nwill appear here automatically.",
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = list[i];
                return FadeSlideIn(
                  index: i,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(p.diagnosis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.14), borderRadius: BorderRadius.circular(999)),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.hourglass_bottom_rounded, size: 12, color: AppColors.warning),
                                SizedBox(width: 4),
                                Text("Pending", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("From ${p.doctorAtSign}",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const Divider(height: 22),
                        ...p.medicines.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.circle, size: 5, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text("${m.name} — ${m.dosage}, ${m.frequency}, ${m.duration}",
                                        style: const TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _dispense(p),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text("Mark dispensed"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

