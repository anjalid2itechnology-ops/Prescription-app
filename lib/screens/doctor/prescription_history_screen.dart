import "package:flutter/material.dart";
import "../../models/prescription.dart";
import "../../services/prescription_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class PrescriptionHistoryScreen extends StatefulWidget {
  final String doctorId;
  const PrescriptionHistoryScreen({super.key, required this.doctorId});

  @override
  State<PrescriptionHistoryScreen> createState() => _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  late Future<List<Prescription>> _future;
  final _searchCtrl = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    _future = PrescriptionService().getHistoryForDoctor(widget.doctorId);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _future = PrescriptionService().getHistoryForDoctor(widget.doctorId));

  List<Prescription> _filter(List<Prescription> list) {
    if (_query.isEmpty) return list;
    return list.where((p) {
      final diagnosisMatch = p.diagnosis.toLowerCase().contains(_query);
      final medicineMatch = p.medicines.any((m) => m.name.toLowerCase().contains(_query));
      return diagnosisMatch || medicineMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: "Search by diagnosis or medicine...",
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => _searchCtrl.clear(),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: FutureBuilder<List<Prescription>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const AppLoading();
                final filtered = _filter(snapshot.data!);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: _query.isEmpty
                        ? "No prescriptions written yet.\nTap \"New prescription\" to get started."
                        : "No prescriptions match \"$_query\".",
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _PrescriptionCard(prescription: filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(prescription.diagnosis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: prescription.dispensed
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    prescription.dispensed ? "Dispensed" : "Pending",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: prescription.dispensed ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...prescription.medicines.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "\u2022 ${m.name} \u2014 ${m.dosage}, ${m.frequency}, ${m.duration}",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                )),
            if (prescription.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text("Notes: ${prescription.notes}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
